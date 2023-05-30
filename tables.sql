SET ECHO ON

-- -----------------------------------------------------------------------------
--       TABLE : CRP_INVOICE_UNIT
-- -----------------------------------------------------------------------------
CREATE TABLE CRP_INVOICE_UNIT
   (
    INV_ID NUMBER(4)  NOT NULL,
    INV_UNIT VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_INVOICE_UNIT PRIMARY KEY (INV_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_PERSON
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_PERSON
   (
    PER_ID NUMBER(4)  NOT NULL,
    PER_ROL_ID NUMBER(2) 
      DEFAULT 1 NOT NULL,
    PER_USERNAME VARCHAR2(128)  NOT NULL,
    PER_PSW VARCHAR2(128)  NOT NULL,
    PER_FIRSTNAME VARCHAR2(128)  NOT NULL,
    PER_LASTNAME VARCHAR2(128)  NOT NULL,
    PER_TEL VARCHAR2(128)  NULL,
    PER_MAIL VARCHAR2(128)  NULL,
    PER_IS_DELETED NUMBER(1) 
      DEFAULT 0 NOT NULL
,   CONSTRAINT PK_CRP_PERSON PRIMARY KEY (PER_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_PERSON
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_PERSON_CRP_ROLE
     ON CRP_PERSON (PER_ROL_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_SERVICE
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_SERVICE
   (
    SER_CODE VARCHAR2(128)  NOT NULL,
    SER_TIM_ID NUMBER(4)  NULL,
    SER_INV_ID NUMBER(4)  NOT NULL,
    SER_NAME VARCHAR2(300)  NOT NULL,
    SER_PRICE_PER_UNIT NUMBER(4)  NOT NULL
,   CONSTRAINT PK_CRP_SERVICE PRIMARY KEY (SER_CODE)  
   ) ;

COMMENT ON COLUMN CRP_SERVICE.SER_PRICE_PER_UNIT
     IS 'increment * price per unit => total invoiced';

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_SERVICE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_SERVICE_CRP_TIME_UNIT
     ON CRP_SERVICE (SER_TIM_ID ASC)
    ;

CREATE  INDEX I_FK_CRP_SERVICE_CRP_INVOICE_U
     ON CRP_SERVICE (SER_INV_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_PATIENT
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_PATIENT
   (
    PAT_PER_ID NUMBER(4)  NOT NULL,
    PAT_INS_ID NUMBER(4)  NULL,
    PAT_IS_DELETED NUMBER(1) 
      DEFAULT 0 NOT NULL
,   CONSTRAINT PK_CRP_PATIENT PRIMARY KEY (PAT_PER_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_PATIENT
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_PATIENT_CRP_INSURANCE
     ON CRP_PATIENT (PAT_INS_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_WEEKDAY
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_WEEKDAY
   (
    WKD_ID NUMBER(4)  NOT NULL,
    WKD_NAME VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_WEEKDAY PRIMARY KEY (WKD_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_APPOINTMENT
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_APPOINTMENT
   (
    APP_ID NUMBER(4)  NOT NULL,
    APP_PAT_ID NUMBER(4)  NOT NULL,
    APP_DOC_ID NUMBER(4)  NOT NULL,
    APP_CREATED_DATE DATE  NOT NULL,
    APP_APTN_DATE DATE  NOT NULL,
    APP_CNL_DATE DATE  NULL,
    APP_CNL_REASON VARCHAR2(128)  NULL,
    APP_IS_INVOICED NUMBER(1) DEFAULT 0 NOT NULL,
    APP_DESC VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_APPOINTMENT PRIMARY KEY (APP_ID)  
   ) ;

COMMENT ON COLUMN CRP_APPOINTMENT.APP_CREATED_DATE
     IS 'when the appointment is created';

COMMENT ON COLUMN CRP_APPOINTMENT.APP_APTN_DATE
     IS 'when the appointment occurs';

COMMENT ON COLUMN CRP_APPOINTMENT.APP_CNL_DATE
     IS 'when the appointment is cancelled';

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_APPOINTMENT
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_APPOINTMENT_CRP_DOC
     ON CRP_APPOINTMENT (APP_DOC_ID ASC)
    ;

CREATE  INDEX I_FK_CRP_APPOINTMENT_CRP_PATIE
     ON CRP_APPOINTMENT (APP_PAT_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_SPECIALTY
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_SPECIALTY
   (
    SPE_ID NUMBER(4)  NOT NULL,
    SPE_NAME VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_SPECIALTY PRIMARY KEY (SPE_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_MEDICATION
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_MEDICATION
   (
    MED_ID NUMBER(4)  NOT NULL,
    MED_NAME VARCHAR2(128)  NOT NULL,
    MED_DESCRIPTION VARCHAR2(128)  NULL
,   CONSTRAINT PK_CRP_MEDICATION PRIMARY KEY (MED_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_AVAILABILITY
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_AVAILABILITY
   (
    AVL_PER_ID NUMBER(4)  NOT NULL,
    AVL_WKD_ID NUMBER(4)  NOT NULL,
    AVL_POD_ID NUMBER(4)  NOT NULL,
    AVL_IS_AVAILABLE NUMBER(1)  NOT NULL
,   CONSTRAINT PK_CRP_AVAILABILITY PRIMARY KEY (AVL_PER_ID, AVL_WKD_ID, AVL_POD_ID)  
   ) ;

COMMENT ON COLUMN CRP_AVAILABILITY.AVL_IS_AVAILABLE
     IS 'True => Available / False => Not present';

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_AVAILABILITY
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_AVAILABILITY_CRP_DOC
     ON CRP_AVAILABILITY (AVL_PER_ID ASC)
    ;

CREATE  INDEX I_FK_CRP_AVAILABILITY_CRP_PERI
     ON CRP_AVAILABILITY (AVL_POD_ID ASC)
    ;

CREATE  INDEX I_FK_CRP_AVAILABILITY_CRP_WEEK
     ON CRP_AVAILABILITY (AVL_WKD_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_PERIODOFDAY
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_PERIODOFDAY
   (
    POD_ID NUMBER(4)  NOT NULL,
    POD_NAME VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_PERIODOFDAY PRIMARY KEY (POD_ID)  
   ) ;

COMMENT ON COLUMN CRP_PERIODOFDAY.POD_NAME
     IS 'AM, PM, Full Day';

-- -----------------------------------------------------------------------------
--       TABLE : CRP_DOC
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_DOC
   (
    DOC_PER_ID NUMBER(4)  NOT NULL,
    DOC_SPE_ID NUMBER(4)  NOT NULL,
    DOC_FEE_PER_CONSULT NUMBER(4)  NOT NULL,
    DOC_START_WORK_DATE DATE  NULL,
    DOC_IS_DELETED NUMBER(1) 
      DEFAULT 0 NULL
,   CONSTRAINT PK_CRP_DOC PRIMARY KEY (DOC_PER_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_DOC
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_DOC_CRP_SPECIALTY
     ON CRP_DOC (DOC_SPE_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_INSURANCE
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_INSURANCE
   (
    INS_ID NUMBER(4)  NOT NULL,
    INS_NAME VARCHAR2(128)  NOT NULL,
    INS_ADDRESS VARCHAR2(128)  NULL
,   CONSTRAINT PK_CRP_INSURANCE PRIMARY KEY (INS_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_ROLE
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_ROLE
   (
    ROL_ID NUMBER(2) 
      DEFAULT 1 NOT NULL,
    ROL_NAME VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_ROLE PRIMARY KEY (ROL_ID)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_TIME_UNIT
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_TIME_UNIT
   (
    TIM_ID NUMBER(4)  NOT NULL,
    TIM_INCREMENT NUMBER(2)  NOT NULL
,   CONSTRAINT PK_CRP_TIME_UNIT PRIMARY KEY (TIM_ID)  
   ) ;

COMMENT ON COLUMN CRP_TIME_UNIT.TIM_INCREMENT
     IS 'per 5 /10/30/60 min';

-- -----------------------------------------------------------------------------
--       TABLE : CRP_PRESCRIPTION
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_PRESCRIPTION
   (
    PRE_APP_ID NUMBER(4)  NOT NULL,
    PRE_MED_ID NUMBER(4)  NOT NULL,
    PRE_DESCRIPTION VARCHAR2(128)  NOT NULL
,   CONSTRAINT PK_CRP_PRESCRIPTION PRIMARY KEY (PRE_APP_ID, PRE_MED_ID)  
   ) ;

COMMENT ON COLUMN CRP_PRESCRIPTION.PRE_DESCRIPTION
     IS 'Where the to will put the advice on how to take the medication';

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_PRESCRIPTION
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_PRESCRIPTION_CRP_APPO
     ON CRP_PRESCRIPTION (PRE_APP_ID ASC)
    ;

CREATE  INDEX I_FK_CRP_PRESCRIPTION_CRP_MEDI
     ON CRP_PRESCRIPTION (PRE_MED_ID ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CRP_SERVICE_PROVIDED
-- -----------------------------------------------------------------------------

CREATE TABLE CRP_SERVICE_PROVIDED
   (
    SPR_APP_ID NUMBER(4)  NOT NULL,
    SPR_SER_CODE VARCHAR2(128)  NOT NULL,
    SPR_DURATION NUMBER(2)  NULL
,   CONSTRAINT PK_CRP_SERVICE_PROVIDED PRIMARY KEY (SPR_APP_ID, SPR_SER_CODE)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CRP_SERVICE_PROVIDED
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CRP_SERVICE_PROVIDED_CRP_
     ON CRP_SERVICE_PROVIDED (SPR_APP_ID ASC)
    ;

CREATE  INDEX I_FK_CRP_SERVICE_PROVIDED_CRP1
     ON CRP_SERVICE_PROVIDED (SPR_SER_CODE ASC)
    ;


-- -----------------------------------------------------------------------------
--       CREATION DES REFERENCES DE TABLE
-- -----------------------------------------------------------------------------


ALTER TABLE CRP_PERSON ADD (
     CONSTRAINT FK_CRP_PERSON_CRP_ROLE
          FOREIGN KEY (PER_ROL_ID)
               REFERENCES CRP_ROLE (ROL_ID))   ;

ALTER TABLE CRP_SERVICE ADD (
     CONSTRAINT FK_CRP_SERVICE_CRP_TIME_UNIT
          FOREIGN KEY (SER_TIM_ID)
               REFERENCES CRP_TIME_UNIT (TIM_ID))   ;

ALTER TABLE CRP_SERVICE ADD (
     CONSTRAINT FK_CRP_SERVICE_CRP_INVOICE_UNI
          FOREIGN KEY (SER_INV_ID)
               REFERENCES CRP_INVOICE_UNIT (INV_ID))   ;

ALTER TABLE CRP_PATIENT ADD (
     CONSTRAINT FK_CRP_PATIENT_CRP_INSURANCE
          FOREIGN KEY (PAT_INS_ID)
               REFERENCES CRP_INSURANCE (INS_ID))   ;

ALTER TABLE CRP_PATIENT ADD (
     CONSTRAINT FK_CRP_PATIENT_CRP_PERSON
          FOREIGN KEY (PAT_PER_ID)
               REFERENCES CRP_PERSON (PER_ID))   ;

ALTER TABLE CRP_APPOINTMENT ADD (
     CONSTRAINT FK_CRP_APPOINTMENT_CRP_DOC
          FOREIGN KEY (APP_DOC_ID)
               REFERENCES CRP_DOC (DOC_PER_ID))   ;

ALTER TABLE CRP_APPOINTMENT ADD (
     CONSTRAINT FK_CRP_APPOINTMENT_CRP_PATIENT
          FOREIGN KEY (APP_PAT_ID)
               REFERENCES CRP_PATIENT (PAT_PER_ID))   ;

ALTER TABLE CRP_AVAILABILITY ADD (
     CONSTRAINT FK_CRP_AVAILABILITY_CRP_DOC
          FOREIGN KEY (AVL_PER_ID)
               REFERENCES CRP_DOC (DOC_PER_ID))   ;

ALTER TABLE CRP_AVAILABILITY ADD (
     CONSTRAINT FK_CRP_AVAILABILITY_CRP_PERIOD
          FOREIGN KEY (AVL_POD_ID)
               REFERENCES CRP_PERIODOFDAY (POD_ID))   ;

ALTER TABLE CRP_AVAILABILITY ADD (
     CONSTRAINT FK_CRP_AVAILABILITY_CRP_WEEKDA
          FOREIGN KEY (AVL_WKD_ID)
               REFERENCES CRP_WEEKDAY (WKD_ID))   ;

ALTER TABLE CRP_DOC ADD (
     CONSTRAINT FK_CRP_DOC_CRP_SPECIALTY
          FOREIGN KEY (DOC_SPE_ID)
               REFERENCES CRP_SPECIALTY (SPE_ID))   ;

ALTER TABLE CRP_DOC ADD (
     CONSTRAINT FK_CRP_DOC_CRP_PERSON
          FOREIGN KEY (DOC_PER_ID)
               REFERENCES CRP_PERSON (PER_ID))   ;

ALTER TABLE CRP_PRESCRIPTION ADD (
     CONSTRAINT FK_CRP_PRESCRIPTION_CRP_APPOIN
          FOREIGN KEY (PRE_APP_ID)
               REFERENCES CRP_APPOINTMENT (APP_ID))   ;

ALTER TABLE CRP_PRESCRIPTION ADD (
     CONSTRAINT FK_CRP_PRESCRIPTION_CRP_MEDICA
          FOREIGN KEY (PRE_MED_ID)
               REFERENCES CRP_MEDICATION (MED_ID))   ;

ALTER TABLE CRP_SERVICE_PROVIDED ADD (
     CONSTRAINT FK_CRP_SERVICE_PROVIDED_CRP_AP
          FOREIGN KEY (SPR_APP_ID)
               REFERENCES CRP_APPOINTMENT (APP_ID))   ;

ALTER TABLE CRP_SERVICE_PROVIDED ADD (
     CONSTRAINT FK_CRP_SERVICE_PROVIDED_CRP_SE
          FOREIGN KEY (SPR_SER_CODE)
               REFERENCES CRP_SERVICE (SER_CODE))   ;


-- -----------------------------------------------------------------------------
--                FIN DE GENERATION
-- -----------------------------------------------------------------------------

EXIT