SET ECHO ON

-- ====================================================================
-- Script : triggers.sql
-- Goal   : Create all triggers for the CArepoint creation
-- Type of trigger created :
--  - AutoIncrement for Primary Key generation Before Insert
-- ====================================================================

-- ====================================================
-- Medication - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_medication MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_medication BEFORE INSERT ON crp_medication FOR each ROW 
BEGIN
    SELECT
      sq_medication.nextval INTO :NEW.med_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_medication ENABLE;
/ 

-- ====================================================
-- Time Unit - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_time_unit MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_time_unit BEFORE INSERT ON CRP_TIME_UNIT FOR each ROW 
BEGIN
    SELECT
      sq_time_unit.nextval INTO :NEW.tim_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_time_unit ENABLE;
/ 

-- ====================================================
-- Invoice Unit - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_invoice_unit MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_invoice_unit BEFORE INSERT ON CRP_INVOICE_UNIT FOR each ROW 
BEGIN
    SELECT
      sq_invoice_unit.nextval INTO :NEW.inv_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_invoice_unit ENABLE;
/ 

-- ====================================================
-- Weekday - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_weekday MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_weekday BEFORE INSERT ON CRP_WEEKDAY FOR each ROW 
BEGIN
    SELECT
      sq_weekday.nextval INTO :NEW.wkd_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_weekday ENABLE;
/ 

-- ====================================================
-- Period of the day - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_periodofday MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_periodofday BEFORE INSERT ON CRP_PERIODOFDAY FOR each ROW 
BEGIN
    SELECT
      sq_periodofday.nextval INTO :NEW.pod_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_periodofday ENABLE;
/ 


-- ====================================================
-- Insurance - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_insurance MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_insurance BEFORE INSERT ON CRP_INSURANCE FOR each ROW 
BEGIN
    SELECT
      sq_insurance.nextval INTO :NEW.ins_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_insurance ENABLE;
/ 

-- ====================================================
-- Specialty - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_specialty MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_specialty BEFORE INSERT ON CRP_SPECIALTY FOR each ROW 
BEGIN
    SELECT
      sq_specialty.nextval INTO :NEW.spe_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_specialty ENABLE;
/ 

-- ====================================================
-- Role - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_role MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_role BEFORE INSERT ON CRP_ROLE FOR each ROW 
BEGIN
    SELECT
      sq_role.nextval INTO :NEW.rol_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_role ENABLE;
/ 

-- ====================================================
-- Person - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_person MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_person BEFORE INSERT ON CRP_PERSON FOR each ROW 
BEGIN
    SELECT
      sq_person.nextval INTO :NEW.per_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_person ENABLE;
/ 

-- ====================================================
-- Appointment - Auto Increment
-- ====================================================
CREATE SEQUENCE sq_appointment MINVALUE 1 NOMAXVALUE INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE 
/ 

CREATE OR REPLACE TRIGGER trg_auto_inc_appointment BEFORE INSERT ON CRP_APPOINTMENT FOR each ROW 
BEGIN
    SELECT
      sq_appointment.nextval INTO :NEW.app_id
    FROM
      dual;
END;
/ 

ALTER TRIGGER trg_auto_inc_appointment ENABLE;
/ 

-- ====================================================
-- Patient - Insert
-- ====================================================
CREATE OR REPLACE TRIGGER TRG_INSERT_VW_PATIENTS 
INSTEAD OF INSERT ON VW_PATIENTS 
FOR EACH ROW
DECLARE
    person_id crp_person.per_id%TYPE;
BEGIN
    -- INSERT IN PERSON
    INSERT INTO CRP_PERSON (per_username, per_psw, per_firstname, per_lastname, per_tel, per_mail, per_rol_id) 
    VALUES (:NEW.per_username, :NEW.per_psw, :NEW.per_firstname, :NEW.per_lastname, :NEW.per_tel, :NEW.per_mail, 2)
    RETURNING per_id INTO person_id;

    -- INSERT IN PATIENT
    INSERT INTO CRP_PATIENT (pat_per_id, pat_ins_id) 
    VALUES (person_id, :NEW.pat_ins_id);
    
END TRG_INSERT_VW_PATIENTS;
/

ALTER TRIGGER TRG_INSERT_VW_PATIENTS ENABLE;
/ 


-- ====================================================
-- Patient - Update
-- ====================================================
create or replace TRIGGER TRG_UPDATE_VW_PATIENTS 
INSTEAD OF UPDATE ON VW_PATIENTS 
FOR EACH ROW
BEGIN
    -- UPDATE PERSON
    UPDATE CRP_PERSON 
    SET per_username = :NEW.per_username,  per_psw = :NEW.per_psw, per_firstname  = :NEW.per_firstname, per_lastname = :NEW.per_lastname, per_tel = :NEW.per_tel, per_mail = :NEW.per_mail
    WHERE per_id = :OLD.per_id;
    
    -- UPDATE IN DOCTOR
    UPDATE CRP_PATIENT
    SET pat_ins_id = :NEW.pat_ins_id
    WHERE pat_per_id = :OLD.per_id;

END TRG_UPDATE_VW_PATIENTS;
/

ALTER TRIGGER TRG_UPDATE_VW_PATIENTS ENABLE;
/ 

-- ====================================================
-- Patient - DELETE
-- ====================================================
create or replace TRIGGER TRG_DELETE_VW_PATIENTS 
INSTEAD OF DELETE ON VW_PATIENTS 
FOR EACH ROW
BEGIN
  UPDATE CRP_PERSON SET PER_IS_DELETED = 1 WHERE PER_ID = :OLD.PER_ID;
  UPDATE CRP_PATIENT SET PAT_IS_DELETED = 1 WHERE PAT_PER_ID = :OLD.PER_ID;
END TRG_DELETE_VW_PATIENTS;
/

ALTER TRIGGER TRG_DELETE_VW_PATIENTS ENABLE;
/ 


-- ====================================================
-- Doctors - Insert
-- ====================================================
CREATE OR REPLACE TRIGGER TRG_INSERT_VW_DOCTORS 
INSTEAD OF INSERT ON VW_DOCTORS 
FOR EACH ROW
DECLARE
    person_id crp_person.per_id%TYPE;
BEGIN
    -- INSERT IN PERSON
    INSERT INTO CRP_PERSON (per_username, per_psw, per_firstname, per_lastname, per_tel, per_mail, per_rol_id)  
    VALUES (:NEW.per_username, :NEW.per_psw, :NEW.per_firstname, :NEW.per_lastname, :NEW.per_tel, :NEW.per_mail, 3)
    RETURNING per_id INTO person_id;

    -- INSERT IN DOCTOR
    INSERT INTO CRP_DOC (doc_per_id, doc_fee_per_consult, doc_start_work_date, doc_spe_id) 
    VALUES (person_id, :NEW.doc_fee_per_consult, :NEW.doc_start_work_date, :NEW.doc_spe_id);
    
END TRG_INSERT_VW_DOCTORS;
/

ALTER TRIGGER TRG_INSERT_VW_DOCTORS ENABLE;
/ 

-- ====================================================
-- Doctors - Update
-- ====================================================
create or replace TRIGGER TRG_UPDATE_VW_DOCTORS 
INSTEAD OF UPDATE ON VW_DOCTORS 
FOR EACH ROW
BEGIN
      -- UPDATE PERSON
    UPDATE CRP_PERSON 
    SET per_username = :NEW.per_username,  per_psw = :NEW.per_psw, per_firstname  = :NEW.per_firstname, per_lastname = :NEW.per_lastname, per_tel = :NEW.per_tel, per_mail = :NEW.per_mail
    WHERE per_id = :OLD.per_id;
    
    -- UPDATE IN DOCTOR
    UPDATE CRP_DOC 
    SET doc_fee_per_consult = :NEW.doc_fee_per_consult, doc_start_work_date = :NEW.doc_start_work_date, doc_spe_id = :NEW.doc_spe_id
    WHERE doc_per_id = :OLD.per_id;
END TRG_UPDATE_VW_DOCTORS;
/

ALTER TRIGGER TRG_UPDATE_VW_DOCTORS ENABLE;
/ 

-- ====================================================
-- Doctor - DELETE
-- ====================================================
create or replace TRIGGER TRG_DELETE_VW_DOCTORS 
INSTEAD OF DELETE ON VW_DOCTORS 
FOR EACH ROW
BEGIN
  UPDATE CRP_PERSON SET PER_IS_DELETED = 1 WHERE PER_ID = :OLD.PER_ID;
  UPDATE CRP_DOC SET DOC_IS_DELETED = 1 WHERE DOC_PER_ID = :OLD.PER_ID;
END TRG_DELETE_VW_DOCTORS;
/

ALTER TRIGGER TRG_DELETE_VW_DOCTORS ENABLE;
/ 

EXIT
