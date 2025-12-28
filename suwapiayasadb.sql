-- Drop Database if exists same name
DROP DATABASE IF EXISTS suwapiyasadb;
-- Create SuwapiyasaDB
CREATE DATABASE suwapiyasadb;
-- Use Database suwapiyasaDB
USE suwapiyasadb;

-- Create table STAFF
CREATE TABLE staff (
    employee_no INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender ENUM('M','F','O') DEFAULT 'O',
    address VARCHAR(255),
    phone VARCHAR(20),
    staff_type ENUM('Doctor','Surgeon','Nurse') NOT NULL,
    salary DECIMAL(10,2),
    UNIQUE(phone),
    CHECK (
        (staff_type = 'Surgeon' AND salary IS NULL)
        OR (staff_type <> 'Surgeon' AND salary IS NOT NULL)
    )
);
-- Q.5 122512608
LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/staff.xml"
INTO TABLE suwapiyasadb.staff
ROWS IDENTIFIED BY '<staff>';

SELECT * FROM staff;

-- Create table SURGEON DETAILS
CREATE TABLE surgeon_details (
    employee_no INT PRIMARY KEY,
    specialty VARCHAR(100) NOT NULL,
    contract_type VARCHAR(50) NOT NULL,
    contract_length_months INT NOT NULL CHECK (contract_length_months > 0),
    FOREIGN KEY (employee_no) REFERENCES staff(employee_no)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table HEAD DOCTOR
CREATE TABLE head_doctor (
    hd_no VARCHAR(20) PRIMARY KEY,
    employee_no INT UNIQUE,
    FOREIGN KEY (employee_no) REFERENCES staff(employee_no)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Create table DOCTOR
CREATE TABLE doctor (
    employee_no INT PRIMARY KEY,
    specialty VARCHAR(100) NOT NULL,
    head_hd_no VARCHAR(20),
    FOREIGN KEY (employee_no) REFERENCES staff(employee_no)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (head_hd_no) REFERENCES head_doctor(hd_no)
        ON DELETE SET NULL ON UPDATE CASCADE
);


-- Create table NURSE
CREATE TABLE nurse (
    employee_no INT PRIMARY KEY,
    grade VARCHAR(50) NOT NULL,
    years_experience INT NOT NULL CHECK (years_experience >= 0),
    surgery_skill_type VARCHAR(100),
    FOREIGN KEY (employee_no) REFERENCES staff(employee_no)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Create table PATIENT
CREATE TABLE patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    age INT CHECK (age >= 0 AND age <= 130),
    address VARCHAR(255),
    phone VARCHAR(20),
    blood_type ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    UNIQUE(phone)
);
-- Q.5 122512608
LOAD XML
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/patient.xml"
INTO TABLE suwapiyasadb.patient
ROWS IDENTIFIED BY '<patient>';

SELECT * FROM patient;

-- Create table Allergies
CREATE TABLE patient_allergy (
    patient_id INT,
    allergy VARCHAR(100),
    PRIMARY KEY (patient_id, allergy),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Create table PATIENT LOCATION
CREATE TABLE patient_location (
    patient_id INT PRIMARY KEY,
    bed_no VARCHAR(10),
    room_no VARCHAR(10),
    nursing_unit VARCHAR(50),
    assigned_from DATE NOT NULL,
    assigned_to DATE NULL,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table MEDICATION
CREATE TABLE medication (
    med_code VARCHAR(20) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    qty_on_hand INT NOT NULL,
    qty_ordered INT DEFAULT 0,
    cost DECIMAL(10,2) NOT NULL,
    expiration_date DATE NOT NULL
);

-- Create table Medication interactions
CREATE TABLE medication_interaction (
    med_code1 VARCHAR(20),
    med_code2 VARCHAR(20),
    severity ENUM('Low','Moderate','Severe'),
    PRIMARY KEY (med_code1, med_code2),
    FOREIGN KEY (med_code1) REFERENCES medication(med_code),
    FOREIGN KEY (med_code2) REFERENCES medication(med_code),
    CHECK (med_code1 <> med_code2)
);


-- Create table PATIENT MEDICATION
CREATE TABLE patient_medication (
    patient_id INT,
    med_code VARCHAR(20),
    dosage VARCHAR(100),
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (patient_id, med_code),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (med_code) REFERENCES medication(med_code)
);

-- Create table SURGERIES
CREATE TABLE surgery (
    surgery_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    surgery_name VARCHAR(150) NOT NULL,
    surgery_date DATE NOT NULL,
    surgery_time TIME NOT NULL,
    category VARCHAR(100),
    special_needs VARCHAR(255),
    theatre VARCHAR(50),
    surgeon_emp_no INT NOT NULL,
    status ENUM('Planned','Scheduled','Completed','Cancelled') DEFAULT 'Planned',
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (surgeon_emp_no) REFERENCES surgeon_details(employee_no)
);

-- Create table NURSES IN SURGERY
CREATE TABLE surgery_nurse_assignment (
    surgery_id INT,
    nurse_emp_no INT,
    assigned_role VARCHAR(100),
    PRIMARY KEY (surgery_id, nurse_emp_no),
    FOREIGN KEY (surgery_id) REFERENCES surgery(surgery_id)
        ON DELETE CASCADE,
    FOREIGN KEY (nurse_emp_no) REFERENCES nurse(employee_no)
);

-- INSERT SAMPLE DATA
INSERT INTO staff(first_name,last_name,gender,address,phone,staff_type,salary) VALUES
('Lahiru','Perera','M','Colombo','0111111111','Doctor',85000),
('Nadeesha','Fernando','F','Colombo','0111111112','Doctor',90000),
('Sunil','Jayawardena','M','Colombo','0111111113','Surgeon',NULL),
('Hashini','Silva','F','Colombo','0111111114','Nurse',50000),
('Amal','Kumar','M','Colombo','0111111115','Nurse',48000),
('Priyanka','Wijesinghe','F','Colombo','0111111116','Nurse',52000),
('Ruwan','De Silva','M','Colombo','0111111117','Doctor',88000),
('Yasas','Ranaweera','M','Colombo','0111111118','Nurse',47000);
SELECT * FROM staff;

-- Surgeon details
INSERT INTO surgeon_details VALUES
(3,'Cardiac Surgery','Contract',24);
SELECT * FROM surgeon_details;

-- Head doctor
INSERT INTO head_doctor VALUES ('HD01',1);
SELECT * FROM head_doctor;

-- Doctors
INSERT INTO doctor VALUES
(1,'General Medicine','HD01'),
(2,'Pediatrics','HD01'),
(7,'Orthopedics',NULL);
SELECT * FROM doctor;

-- Nurses
INSERT INTO nurse VALUES
(4,'Grade I',4,'Scrub'),
(5,'Grade II',2,'Circulating'),
(6,'Grade I',6,'Scrub'),
(8,'Grade III',1,'Recovery');
SELECT * FROM nurse;

-- Patients
INSERT INTO patient(name,age,address,phone,blood_type) VALUES
('Kumar D',45,'Colombo','0777777771','O+'),
('S. Perera',60,'Colombo','0777777772','A+');
SELECT * FROM patient;

-- Allergies
INSERT INTO patient_allergy VALUES
(1,'Penicillin'),
(1,'Dust');
SELECT * FROM patient_allergy;

-- Locations
INSERT INTO patient_location VALUES
(1,'B12','R1','Unit A','2025-11-20',NULL),
(2,'C05','R2','Unit B','2025-11-19',NULL);
SELECT * FROM patient_location;

-- Medications
INSERT INTO medication VALUES
('MED001','Paracetamol',500,200,0.10,'2026-12-31'),
('MED002','Amoxicillin',200,50,0.50,'2026-06-30'),
('MED003','Warfarin',50,0,2.00,'2025-11-30');
SELECT * FROM medication;

-- Interactions
INSERT INTO medication_interaction VALUES
('MED001','MED002','Low'),
('MED002','MED003','Severe');
SELECT * FROM medication_interaction;

-- Patient medications
INSERT INTO patient_medication VALUES
(1,'MED001','500mg TID','2025-11-20',NULL),
(2,'MED003','2mg daily','2025-11-18',NULL);
SELECT * FROM patient_medication;

-- Surgeries
INSERT INTO surgery(patient_id,surgery_name,surgery_date,surgery_time,category,special_needs,theatre,surgeon_emp_no,status)
VALUES
(1,'Appendectomy','2025-11-21','09:00','Emergency','None','Theatre A',3,'Scheduled'),
(2,'Knee Arthroscopy','2025-11-22','14:00','Elective','Special equipment','Theatre B',3,'Planned');
SELECT * FROM surgery;

-- Nurse assignments
INSERT INTO surgery_nurse_assignment VALUES
(1,4,'Scrub'),
(1,6,'Circulating'),
(2,5,'Scrub'),
(2,8,'Circulating');
SELECT * FROM surgery_nurse_assignment;
