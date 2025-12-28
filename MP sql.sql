-- Q1- 122512608 --
DROP VIEW IF EXISTS view_patient_surgery;
CREATE VIEW v_patient_surgery AS
	SELECT 
		p.patient_id,
        -- Create name with initial 
		CONCAT(UPPER(LEFT(p.name,1)),'. ',
			SUBSTRING_INDEX(P.name, ' ', -1)
		) AS patient_name,
        CONCAT(pl.bed_no, ' / ', pl.room_no) AS location,
        s.surgery_name,
        s.surgery_date
	FROM patient p
    JOIN patient_location pl ON p.patient_id = pl.patient_id
    JOIN surgery s ON p.patient_id = s.patient_id;
    
SELECT * FROM v_patient_surgery;

-- Q2. 122512608 --
DROP TABLE IF EXISTS MedInfo;
CREATE TABLE MedInfo (
	med_name VARCHAR(150) PRIMARY KEY,
    quantity_available INT,
    expiration_date DATE
);

-- Q2. Crete Trigger --
DELIMITER $$
-- After Insert
DROP TRIGGER IF EXISTS trg_after_insert;
CREATE TRIGGER trg_after_insert
AFTER INSERT ON medication
FOR EACH ROW 
BEGIN
	INSERT INTO MedInfo (med_name, quantity_available, expiration_date)
    VALUES (NEW.name, NEW.qty_on_hand, NEW.expiration_date)
    ON DUPLICATE KEY UPDATE 
		quantity_available = NEW.qty_on_hand,
        expiration_date = NEW.expiration_date;
END $$
-- After Update 
CREATE TRIGGER trg_after_update
AFTER UPDATE ON medication
FOR EACH ROW
BEGIN
	-- If name change, removed old name and update
    IF OLD.name <> OLD.name THEN
    -- remove old if exists
    DELETE FROM MedInfo WHERE med_name = OLD.name;
	END IF;
    INSERT INTO MedInfo(med_name, quantity_available, expiration_date)
	VALUES (NEW.name, NEW.qty_on_hand, NEW.expiration_date)
    ON DUPLICATE KEY UPDATE
		quantity_available = NEW.qty_on_hand,
        expiration_date = NEW.expiration_date;
END $$
-- After Delete
CREATE TRIGGER trg_after_delete
AFTER DELETE ON medication
FOR EACH ROW
BEGIN 
	DELETE FROM MedInfo WHERE med_name = OLD.name;
END $$

DELIMITER ;

-- Q2 - 122512608  Results
-- After creating triggers, insert a new medication to see MedInfo populated
INSERT INTO medication VALUES 
('MED010','TestMed',10,0,1.23,'2026-01-01');
SELECT * FROM MedInfo WHERE med_name='TestMed';

-- Update medication to see MedInfo updated
UPDATE medication SET qty_on_hand = 5 WHERE med_code = 'MED010';
SELECT * FROM MedInfo WHERE med_name='TestMed';

-- Delete medication to see MedInfo row removed
DELETE FROM medication WHERE med_code = 'MED010';
SELECT * FROM MedInfo WHERE med_name='TestMed';

-- Q.3 122512608
DELIMITER $$
CREATE PROCEDURE sp_get_med_count (
	IN p_patient_id INT,
    INOUT p_med_count INT
)
BEGIN
	DECLARE v_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_count
    FROM patient_medication
    WHERE patient_id = p_patient_id;
    
    SET p_med_count = v_count;
END $$

DELIMITER ;

-- Q.3 Results
SET @count_var = 0; -- Initializer
CALL sp_get_med_count(1, @count_var); -- 1 is example, patient id
SELECT @count_var AS medication_count_for_patient_1;

-- Q.4 122512608 
DROP FUNCTION IF EXISTS fn_days_to_expiry;
DELIMITER $$
CREATE FUNCTION fn_days_to_expiry(
	in_med_code VARCHAR(20))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE days_left INT;
    SELECT DATEDIFF(expiration_date, CURDATE()) INTO days_left
    FROM medication
    WHERE med_code = in_med_code
    LIMIT 1;
    
    RETURN days_left;
END$$
DELIMITER ;

-- Q.4 Results
SELECT 
	med_code,
    name,
    qty_on_hand,
    expiration_date,
    DATEDIFF(expiration_date, CURDATE()) AS days_to_expiry,
    fn_days_to_expiry(med_code) AS days_to_expiry_fn
FROM medication
WHERE DATEDIFF(expiration_date, CURDATE()) < 30;

-- Q5. 122512608
-- Example using LOCAL PATH
LOAD XML
INFILE "S:/BSE/staff.xml"
INTO TABLE suwapiyasadb.staff
ROWS IDENTIFIED BY '<staff>'
(
  first_name,
  last_name,
  gender,
  address,
  phone,
  staff_type,
  salary
);

SELECT * FROM staff LIMIT 10;

-- ======================================= Extra task for Practice ======================================= --
-- Full Surgery Team Details
CREATE VIEW v_surgery_team AS
	SELECT
		s.surgery_id,
        p.name AS patient_name,
        s.surgery_name,
        s.surgery_date,
        CONCAT(st.first_name,' ', st.last_name) AS surgeon_name,
        n.employee_no AS nurse_id,
        CONCAT(ns.first_name,' ', ns.last_name) AS nurse_name,
        sna.assigned_role
	FROM surgery s
    JOIN patient p ON s.patient_id = p.patient_id
    JOIN staff st ON s.surgeon_emp_no = st.employee_no
    JOIN surgery_nurse_assignment sna ON s.surgery_id = sna.surgery_id
    JOIN nurse n ON sna.nurse_emp_no = n.employee_no
    JOIN staff ns ON n.employee_no = ns.employee_no;

SELECT * FROM v_surgery_team;

CREATE VIEW v_patient_med_risk AS
	SELECT 
		p.patient_id,
        p.name AS patient_name,
        m.name AS medication,
        mi.med_code2 AS interacting_med,
        mi.severity
	FROM patient_medication pm
    JOIN patient p ON pm.patient_id = p.patient_id
    JOIN medication m ON pm.med_code = m.med_code 
    JOIN medication_interaction mi ON pm.med_code = mi.med_code1;

SELECT * FROM v_patient_med_risk;

CREATE VIEW v_doctor_hierarchy AS
	SELECT
		d.employee_no AS doctor_id,
        CONCAT(s.first_name,' ', s.last_name) AS doctor_name,
        hd.hd_no,
        CONCAT(hs.first_name,' ', hs.last_name) AS head_doctor_name
	FROM doctor d
    JOIN staff s ON d.employee_no = s.employee_no
    LEFT JOIN head_doctor hd ON d.head_hd_no = hd.hd_no
    LEFT JOIN staff hs ON hd.employee_no = hs.employee_no;
        
SELECT * FROM v_doctor_hierarchy;

DROP PROCEDURE IF EXISTS get_surgeries_by_date;
DELIMITER $$
CREATE PROCEDURE get_surgeries_by_date(IN s_date DATE)
BEGIN
	SELECT 
		s.surgery_id,
        p.name AS patient,
        s.surgery_name,
        s.surgery_time,
        CONCAT(st.first_name,' ', st.last_name) AS surgeon
	FROM surgery s
    JOIN patient p ON s.patient_id = p.patient_id
    JOIN staff st ON s.surgeon_emp_no = st.employee_no
    WHERE s.surgery_date = s_date;
END $$
DELIMITER ;

CALL get_surgeries_by_date('2025-11-21');

DELIMITER $$
CREATE PROCEDURE assign_nurse(
	IN p_surgery INT,
    IN p_nurse INT,
    IN p_role VARCHAR(100)
)
BEGIN
	IF EXISTS(
		SELECT 1 FROM surgery_nurse_assignment
        WHERE surgery_id = p_surgery AND nurse_emp_no = p_nurse
    ) THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nurse already assigned';
	ELSE 
		INSERT INTO surgery_nurse_assignment
        VALUE (p_surgery, p_nurse, p_role);
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_nurse_double_booking
BEFORE INSERT ON surgery_nurse_assignment
FOR EACH ROW
BEGIN
	IF EXISTS (
		SELECT 1
        FROM surgery s1
        JOIN surgery s2 ON s1.surgery_date = s2.surgery_date
        JOIN surgery_nurse_assignment sna ON s2.surgery_id = sna.surgery_id
        WHERE sna.nurse_emp_no = NEW.nurse_emp_no
        AND s1.surgery_id = NEW.surgery_id
    ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nurse already assigned to another surgery on same date';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_block_expired_med
BEFORE INSERT ON patient_medication
FOR EACH ROW
BEGIN
	IF EXISTS(
		SELECT 1 FROM medication
        WHERE med_code = NEW.med_code
        AND expiration_date < CURDATE()
    ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medication is expired';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION surgery_count(surgeon_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE total INT;
    
    SELECT COUNT(*) INTO total
    FROM surgery
    WHERE surgeon_emp_no = surgeon_id;
    
    RETURN total;
END$$
DELIMITER ;

SELECT first_name, surgery_count(employee_no)
FROM staff
WHERE staff_type='Surgeon';

DELIMITER $$
CREATE FUNCTION is_patient_admitted(pid INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN 
	RETURN EXISTS (
		SELECT 1 FROM patient_location
        WHERE patient_id = pid
        AND assigned_to IS NULL
    );
END$$
DELIMITER ;

SELECT name, is_patient_admitted(patient_id)
FROM patient;

-- Create view patient surgery details
CREATE VIEW v_patient_surgery_details AS
SELECT
	p.name AS patient_name,
    CONCAT(pl.bed_no,'/',pl.room_no) AS ward,
    s.surgery_name,
    CONCAT(st.first_name, ' ', st.last_name) AS surgeon
FROM patient p
JOIN patient_location pl ON p.patient_id = pl.patient_id
JOIN surgery s ON p.patient_id = s.patient_id
JOIN staff st ON s.surgeon_emp_no = st.employee_no;

SELECT * FROM v_patient_surgery_details;

-- Create view doctor details
CREATE VIEW v_doctor_reporting AS
SELECT 
	CONCAT(s.first_name,' ', s.last_name) AS doctor_name,
    d.specialty,
    CONCAT(hs.first_name,' ',hs.last_name) AS head_doctor
FROM doctor d
JOIN staff s ON d.employee_no = s.employee_no
LEFT JOIN head_doctor hd ON d.head_hd_no = hd.hd_no
LEFT JOIN staff hs ON hd.employee_no = hs.employee_no;

SELECT * FROM v_doctor_reporting;

-- Store Procedure --
DELIMITER $$
CREATE PROCEDURE get_surgery_nurses(IN sid INT)
BEGIN 
	SELECT
		CONCAT(st.first_name,' ',st.last_name) AS nurse_name,
        sna.assigned_role
	FROM surgery_nurse_assignment sna
    JOIN nurse n ON sna.nurse_emp_no = n.employee_no
    JOIN staff st ON n.employee_no = st.employee_no
    WHERE sna.surgery_id = sid;
END $$
DELIMITER ;

-- Create a procedure to transfer a patient to a new room 
DELIMITER $$
CREATE PROCEDURE transfer_patient(
	IN pid INT,
    IN new_bed INT,
    IN new_room INT,
    IN new_unit INT
)
BEGIN
	UPDATE patient_location
    SET assigned_to = CURDATE()
    WHERE patient_id = pid
		AND assined_to IS NULL;
	
    INSERT INTO patient_location
    VALUES (pid, new_bed, new_room, new_unit, CURDATE(), NULL);
END$$
DELIMITER ;

-- Create a trigger to stop assigning medication if patient is not admitted.

DELIMITER $$
CREATE TRIGGER trg_med_only_if_admitted
BEFORE INSERT ON patient_medication
FOR EACH ROW
BEGIN 
	IF NOT EXISTS (
		SELECT 1 FROM patient_location
        WHERE patient_id = NEW.patient_id
			AND assigned_to IS NULL
	) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'patient not admitted';
	END IF;
    
    END$$
DELIMITER ;

-- Create a trigger to prevent doctor supervising themselves.

DELIMITER $$
CREATE TRIGGER trg_no_self_head
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
	IF EXISTS (
		SELECT 1 FROM head_doctor
        WHERE hd_no = NEW.head_hd_no
        AND employee_no = NEW.employee_no
    ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor Cannot be own head';
	END IF;
END$$
DELIMITER ;

-- Create a function that returns number of nurses assigned to a surgery.

DELIMITER $$
CREATE FUNCTION nurse_count(sid INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE total int;
    
    SELECT COUNT(*) INTO total
    FROM surgery_nurse_assignment
    WHERE surgery_id = sid;
    
    RETURN total;
END$$
DELIMITER ;

-- Create a function that returns total medications given to a patient.

DELIMITER $$
CREATE FUNCTION total_med(pid INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE total INT;
    
	SELECT COUNT(*) INTO total
    FROM patient_medication
    WHERE patient_id = pid;
    
    RETURN total;
END$$
DELIMITER ;

-- block surgery if surgeon is not in surgeon_details

DELIMITER $$
CREATE TRIGGER trg_block_surgery
BEFORE INSERT ON surgery
FOR EACH ROW
BEGIN
	IF NOT EXISTS (
		SELECT 1
        FROM surgeon_details
        WHERE employee_no = NEW.employee_no
    ) THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid surgeon';
	END IF;
END$$
DELIMITER ;

-- Discharg patient
DROP PROCEDURE IF EXISTS discharge_patient;
DELIMITER $$
CREATE PROCEDURE discharge_patient (IN pid INT)
BEGIN
	UPDATE patient_location
    SET assigned_to = CURDATE()
    WHERE patient_id = pid
		AND assigned_to IS NULL;
END $$
DELIMITER ;

CALL discharge_patient(1);

CREATE VIEW v_patient_med_interactions AS
SELECT
	p.name AS patinet_name,
    m1.name AS medication,
    m2.name AS interacting_medication,
    mi.severity
FROM patient_medication
JOIN patient p ON pm.patinet_id = p.patient_id
JOIN medication m1 ON pm.med_code = m1.med_code
JOIN medication_interaction mi ON pm.med_code = mi.med_code1
JOIN medication m2 ON mi.med_code2 = m2.med_code;

-- Create function surgeon workload
DELIMITER $$
CREATE FUNCTION surgeon_workload(surgeon_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE total INT;
    
    SELECT COUNT(*) INTO total
    FROM surgery
    WHERE surgeon_emp_no = surgery_id;
    
    RETURN
		CASE 
			WHEN total <= 2 THEN 'LOW'
            WHEN total <= 5 THEN 'Medium'
            ELSE 'High'
		END;
END $$
DELIMITER ;


SELECT
    CONCAT(first_name,' ',last_name) AS surgeon,
    surgeon_workload(employee_no) AS workload
FROM staff
WHERE staff_type = 'Surgeon';













































