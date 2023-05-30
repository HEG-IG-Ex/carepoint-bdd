SET ECHO ON

-- ====================================================
-- Doctors
-- ====================================================
CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_DOCTORS (
    PER_ID,
    PER_USERNAME,
    PER_PSW,
    PER_FIRSTNAME,
    PER_LASTNAME,
    PER_TEL,
    PER_MAIL,
    DOC_FEE_PER_CONSULT,
    DOC_START_WORK_DATE,
    DOC_SPE_ID,
    SPE_NAME
) AS
SELECT
    PER_ID,
    PER_USERNAME,
    PER_PSW,
    PER_FIRSTNAME,
    PER_LASTNAME,
    PER_TEL,
    PER_MAIL,
    DOC_FEE_PER_CONSULT,
    DOC_START_WORK_DATE,
    DOC_SPE_ID,
    SPE_NAME
FROM
    CRP_PERSON
    INNER JOIN CRP_DOC ON PER_ID = DOC_PER_ID
    LEFT JOIN CRP_SPECIALTY ON DOC_SPE_ID = SPE_ID
WHERE PER_IS_DELETED = 0;
/

CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_DOCTORS_APP (
    "APP_ID", 
    "APP_DOC_ID", 
    "Appointment Date", 
    "Cancellation Date",
    "Cancellation Reason", 
    "Patient Fullname",
    "Description"
) AS 
  SELECT 
    APP_ID,
    APP_DOC_ID,
    APP_APTN_DATE,
    APP_CNL_DATE,
    APP_CNL_REASON,
    PER_FIRSTNAME || ' ' ||PER_LASTNAME,
    APP_DESC
FROM
    CRP_APPOINTMENT
    LEFT JOIN CRP_PATIENT ON APP_PAT_ID = PAT_PER_ID
    LEFt JOIN CRP_PERSON ON PAT_PER_ID = PER_ID;
/

-- ====================================================
-- Patients
-- ====================================================
CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_PATIENTS (
    PER_ID,
    PER_USERNAME,
    PER_PSW,
    PER_FIRSTNAME,
    PER_LASTNAME,
    PER_TEL,
    PER_MAIL,
    PAT_INS_ID,
    INS_NAME,
    INS_ADDRESS
) AS
SELECT
    PER_ID,
    PER_USERNAME,
    PER_PSW,
    PER_FIRSTNAME,
    PER_LASTNAME,
    PER_TEL,
    PER_MAIL,
    PAT_INS_ID,
    INS_NAME,
    INS_ADDRESS
FROM
    CRP_PERSON
    INNER JOIN CRP_PATIENT ON PER_ID = PAT_PER_ID
    LEFT JOIN CRP_INSURANCE ON PAT_INS_ID = INS_ID
WHERE PER_IS_DELETED = 0;
/ 

CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_PATIENTS_APP (
    "APP_ID", 
    "APP_PAT_ID", 
    "Appointment Date",
    "Cancellation Date",
    "Cancellation Reason", 
    "Doctor",
    "Description"
) AS 
  SELECT 
    APP_ID,
    APP_PAT_ID,
    APP_APTN_DATE,
    APP_CNL_DATE,
    APP_CNL_REASON,
    'Dr.' || PER_LASTNAME,
    APP_DESC
FROM
    CRP_APPOINTMENT
    LEFT JOIN CRP_DOC ON APP_DOC_ID = DOC_PER_ID
    LEFt JOIN CRP_PERSON ON DOC_PER_ID = PER_ID;
/


CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_INVOICES (
    "Appointment",
    "Service Code", 
    "Service Name", 
    "Price Step", 
    "Unit Price",
    "Duration OR Count", 
    "Total Price"
) AS 
SELECT
    SPR_APP_ID,
    SPR_SER_CODE,
    SER_NAME,
    CASE INV_ID
        WHEN 1 THEN 'PER ' || TIM_INCREMENT || ' MIN'
        WHEN 2 THEN 'PER OCCURENCE'
    END AS PRICE_STEP,
    SER_PRICE_PER_UNIT,
    SPR_DURATION,
    CASE INV_ID
        WHEN 1 THEN (SPR_DURATION/TIM_INCREMENT) * SER_PRICE_PER_UNIT
        WHEN 2 THEN SPR_DURATION * SER_PRICE_PER_UNIT
    END AS TOTAL_PRICE
FROM
    CRP_SERVICE_PROVIDED
    LEFT JOIN CRP_SERVICE ON SPR_SER_CODE = SER_CODE
    LEFT JOIN CRP_TIME_UNIT ON SER_TIM_ID = TIM_ID
    LEFT JOIN CRP_INVOICE_UNIT ON SER_INV_ID = INV_ID
UNION
SELECT
    APP_ID AS SPR_APP_ID,
    '00001' AS SER_CODE,
    'Dr. ' ||PER_FIRSTNAME ||' ' || PER_LASTNAME || ' - ' || SPE_NAME AS SER_NAME ,
    'PER OCCURENCE' AS PRICE_STEP,
    DOC_FEE_PER_CONSULT,
    1 AS SPR_DURATION,
    DOC_FEE_PER_CONSULT AS TOTAL_PRICE
FROM
    crp_appointment
    JOIN CRP_DOC ON DOC_PER_ID = APP_DOC_ID
    JOIN CRP_PERSON ON PER_ID = DOC_PER_ID
    JOIN CRP_SPECIALTY ON SPE_ID = DOC_SPE_ID
ORDER BY SPR_APP_ID ASC;
/
EXIT