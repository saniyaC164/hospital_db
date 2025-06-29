import psycopg2
from faker import Faker
import random
from datetime import timedelta
from tqdm import tqdm
import os
from dotenv import load_dotenv


load_dotenv()
fake = Faker()


# Connect to PostgreSQL
conn = psycopg2.connect(
    dbname="hospital_data",
    user="postgres",
    password= os.getenv("PASSWORD"), 
    host="localhost",
    port="5432"
)
cur = conn.cursor()

# Step 1: Insert 5 Hospitals
hospitals = ['Apollo Hospitals', 'Fortis Healthcare', 'AIIMS Delhi', 'Nanavati Hospital', 'Kokilaben Hospital']
cur.executemany("INSERT INTO hospital (hospital_name) VALUES (%s)", [(h,) for h in hospitals])
conn.commit()

# Get hospital IDs
cur.execute("SELECT hospital_id FROM hospital")
hospital_ids = [row[0] for row in cur.fetchall()]

# Sample diagnosis and medicines
diagnoses = ['Diabetes', 'Hypertension', 'Asthma', 'Flu', 'COVID-19', 'Arthritis']
medicines = ['Paracetamol', 'Metformin', 'Ibuprofen', 'Amlodipine', 'Salbutamol', 'Vitamin D', 'Azithromycin']

print("Generating and inserting 100,000 patients...")

for _ in tqdm(range(100000)):

    # Patient
    hospital_id = random.choice(hospital_ids)
    patient_name = fake.name()
    dob = fake.date_of_birth(minimum_age=1, maximum_age=90)
    admit_date = fake.date_time_between(start_date='-2y', end_date='now')
    discharge_date = admit_date + timedelta(days=random.randint(1, 10))

    cur.execute("""
        INSERT INTO patient (hospital_id, patient_name, dob, admission_datetime, discharge_datetime)
        VALUES (%s, %s, %s, %s, %s) RETURNING patient_id
    """, (hospital_id, patient_name, dob, admit_date, discharge_date))
    patient_id = cur.fetchone()[0]

    # Diagnoses (2 per patient)
    for _ in range(2):
        cur.execute("""
            INSERT INTO diagnosis (patient_id, diagnosis_name) VALUES (%s, %s)
        """, (patient_id, random.choice(diagnoses)))

    # Medicines (5 per patient)
    for _ in range(5):
        dose_time = admit_date + timedelta(hours=random.randint(1, 48))
        duration = random.randint(1, 7)
        cur.execute("""
            INSERT INTO treatment (patient_id, medicine_name, dose_time, duration)
            VALUES (%s, %s, %s, %s)
        """, (patient_id, random.choice(medicines), dose_time, duration))

    # Billing
    amount = random.uniform(1000, 10000)
    mode = random.choice(['cash', 'credit'])
    cur.execute("""
        INSERT INTO billing (patient_id, bill_amount, payment_mode)
        VALUES (%s, %s, %s)
    """, (patient_id, round(amount, 2), mode))

    # Commit every 1000 records for performance
    if _ % 1000 == 0:
        conn.commit()

# Final commit
conn.commit()
conn.close()
print("✅ Data generation complete.")
