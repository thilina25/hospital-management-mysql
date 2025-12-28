# hospital-management-mysql
This project is a Hospital Management Database System developed as a university project using MySQL 8.0 and MySQL Workbench. It models real-world hospital operations such as staff management, patient admissions, surgeries, medications, and safety rules, enforced at the database level using advanced SQL features.

🛠️ Tools & Technologies
  MySQL 8.0
  MySQL Workbench
  SQL Editor
  EER Diagram Designer
  Data Import (XML)
SQL Features Used
  DDL & DML
  Views
  Stored Procedures
  Triggers
  User Defined Functions (UDF)
  Constraints (PK, FK, CHECK, UNIQUE)
🗂️ Database Design
The system consists of multiple interrelated tables including:
Staff Management
  staff, doctor, head_doctor, surgeon_details, nurse
Patient Management
  patient, patient_location, patient_allergy
Medical Records
  medication, patient_medication, medication_interaction
Surgery Management
  surgery, surgery_nurse_assignment

The schema is fully normalized and maintains referential integrity using foreign keys with cascading rules.

⚙️ Key Features
✅ Views
  Patient surgery and ward details
  Surgery team composition (surgeon + nurses)
  Doctor–Head Doctor hierarchy
  Patient medication interaction risk analysis
✅ Stored Procedures
  Assign nurses to surgeries with conflict checks
  Transfer and discharge patients
  Retrieve surgeries by date
  Count medications per patient
✅ Triggers
  Prevent assigning expired medications
  Block surgery if the surgeon is not registered
  Prevent nurse double-booking on the same date
  Allow medication assignment only if patient is admitted
  Synchronize medication inventory automatically
✅ User Defined Functions (UDFs)
  Calculate days remaining until medication expiry
  Check patient admission status
  Count surgeries per surgeon
  Determine surgeon workload level (Low / Medium / High)
🔐 Data Integrity & Business Rules
  Enforced hospital rules directly in the database:
  Surgeons are contract-based (no salary)
  Doctors cannot supervise themselves
  Patients must be admitted to receive medication
  Nurses cannot be assigned to multiple surgeries on the same day
📂 Data Import
  Staff and patient data imported using XML files
  Implemented via LOAD XML INFILE in MySQL Workbench
