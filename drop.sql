
SET ECHO ON

DROP SYNONYM "USR_APP"."DOCTORS";
DROP SYNONYM "USR_APP"."DOCTORS_NEXT_APP";
DROP SYNONYM "USR_APP"."DOCTORS_PAST_APP";
DROP SYNONYM "USR_APP"."PATIENTS";
DROP SYNONYM "USR_APP"."PATIENTS_NEXT_APP";
DROP SYNONYM "USR_APP"."PATIENTS_PAST_APP";
DROP SYNONYM "USR_APP"."INVOICES";

DROP VIEW VW_DOCTORS;
DROP VIEW VW_DOCTORS_NEXT_APP;
DROP VIEW VW_DOCTORS_PAST_APP;
DROP VIEW VW_PATIENTS;
DROP VIEW VW_PATIENTS_NEXT_APP;
DROP VIEW VW_PATIENTS_PAST_APP;
DROP VIEW VW_INVOICES;

DROP TABLE CRP_INVOICE_UNIT CASCADE CONSTRAINTS;
DROP TABLE CRP_PERSON CASCADE CONSTRAINTS;
DROP TABLE CRP_SERVICE CASCADE CONSTRAINTS;
DROP TABLE CRP_PATIENT CASCADE CONSTRAINTS;
DROP TABLE CRP_WEEKDAY CASCADE CONSTRAINTS;
DROP TABLE CRP_APPOINTMENT CASCADE CONSTRAINTS;
DROP TABLE CRP_SPECIALTY CASCADE CONSTRAINTS;
DROP TABLE CRP_MEDICATION CASCADE CONSTRAINTS;
DROP TABLE CRP_AVAILABILITY CASCADE CONSTRAINTS;
DROP TABLE CRP_PERIODOFDAY CASCADE CONSTRAINTS;
DROP TABLE CRP_DOC CASCADE CONSTRAINTS;
DROP TABLE CRP_INSURANCE CASCADE CONSTRAINTS;
DROP TABLE CRP_ROLE CASCADE CONSTRAINTS;
DROP TABLE CRP_TIME_UNIT CASCADE CONSTRAINTS;
DROP TABLE CRP_PRESCRIPTION CASCADE CONSTRAINTS;
DROP TABLE CRP_SERVICE_PROVIDED CASCADE CONSTRAINTS;

DROP SEQUENCE sq_MEDICATION;
DROP SEQUENCE SQ_TIME_UNIT;
DROP SEQUENCE SQ_INVOICE_UNIT;
DROP SEQUENCE SQ_WEEKDAY;
DROP SEQUENCE SQ_PERIODOFDAY;
DROP SEQUENCE SQ_INSURANCE;
DROP SEQUENCE SQ_SPECIALTY;
DROP SEQUENCE SQ_ROLE;
DROP SEQUENCE SQ_PERSON;
DROP SEQUENCE SQ_APPOINTMENT;

DROP PACKAGE BODY PKG_CAREPOINT;
DROP PACKAGE PKG_CAREPOINT;

EXIT