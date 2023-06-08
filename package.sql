SET ECHO ON

CREATE OR REPLACE EDITIONABLE PACKAGE PKG_CAREPOINT AS

   FUNCTION getNextAvailabilityForDoc (i_doc_id INTEGER) RETURN SYS_REFCURSOR;
   FUNCTION getNextAvailabilityForSpe (i_spe_id INTEGER) RETURN SYS_REFCURSOR;
   FUNCTION getInvoiceForAppointment(i_app_id IN NUMBER) RETURN SYS_REFCURSOR;
   PROCEDURE batchInvoices;

END PKG_CAREPOINT;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY PKG_CAREPOINT AS

    TYPE typ_account_record IS RECORD (
        acc_app_id crp_appointment.app_id%TYPE,
        acc_sap_account CHAR(5),
        acc_transaction_type VARCHAR(6),
        acc_amount vw_invoices."Total Price"%TYPE
    );
    
    TYPE table_accounting IS TABLE OF typ_account_record;

     FUNCTION getNextAvailabilityForDoc(i_doc_id IN INTEGER) RETURN SYS_REFCURSOR AS
        c_availability SYS_REFCURSOR;
    BEGIN
        OPEN c_availability FOR
            WITH next_10_days AS (
                SELECT TRUNC(SYSDATE) + LEVEL - 1 AS availability_date
                FROM DUAL
                CONNECT BY LEVEL <= 10
            ),
            work_hours AS (
                SELECT TO_CHAR(TRUNC(SYSDATE) + 9/24 + (LEVEL-1)/24, 'HH24:MI') AS work_hour
                FROM DUAL
                CONNECT BY LEVEL <= 10
            ),
            availability_query AS (
                SELECT
                    availability_date,
                    work_hour,
                    CASE
                        WHEN work_hour <= '12:00' THEN 1 -- Exclude the morning if current time is before noon
                        ELSE 2 -- Exclude the afternoon if current time is after noon
                    END AS pod,
                    TO_CHAR(availability_date, 'D') AS weekday_number
                FROM
                    next_10_days
                CROSS JOIN
                    work_hours
            ),
            availability_avl_query AS (
                SELECT
                    AVL_PER_ID,
                    AVL_WKD_ID,
                    AVL_POD_ID
                FROM
                    crp_availability
                WHERE
                    AVL_PER_ID = i_doc_id -- Use the input parameter here
                    AND AVL_IS_AVAILABLE = 1
            )
            SELECT
                availability_query.availability_date,
                availability_query.work_hour
            FROM
                availability_query
            INNER JOIN
                availability_avl_query
            ON
                availability_query.pod = availability_avl_query.AVL_POD_ID
                AND availability_query.weekday_number = availability_avl_query.AVL_WKD_ID;
    
        IF c_availability%NOTFOUND THEN
            CLOSE c_availability;
            RAISE_APPLICATION_ERROR(-20002, 'Doctor doesn''t have any availability for the next 10 days');
        END IF;
    
        RETURN c_availability;
    END getNextAvailabilityForDoc;


    FUNCTION getInvoiceForAppointment(i_app_id IN NUMBER) RETURN SYS_REFCURSOR AS
        cur SYS_REFCURSOR;
    BEGIN
        OPEN cur FOR SELECT * FROM VW_INVOICES WHERE "Appointment" = i_app_id;
        RETURN cur;
    END getInvoiceForAppointment;



    FUNCTION createInvoicesAccountingTable RETURN table_accounting AS
    
        CURSOR c_appointment IS SELECT * FROM crp_appointment WHERE APP_IS_INVOICED = 0;
        c_invoice SYS_REFCURSOR;
        r_appointment crp_appointment%ROWTYPE;
        r_invoice_line vw_invoices%ROWTYPE;
                
        tmp_acc table_accounting := table_accounting();

    BEGIN
        
        -- For each appointement not booked yet in accounting    
        OPEN c_appointment;
        FETCH c_appointment INTO r_appointment;
        WHILE c_appointment%FOUND LOOP
            
            -- For each invoice line
            c_invoice := getInvoiceForAppointment(r_appointment.app_id);
            FETCH c_invoice INTO r_invoice_line;
            WHILE c_invoice%FOUND LOOP
                
                -- Book Debit in Account Receivable Account(10001)
                tmp_acc.EXTEND;
                tmp_acc(tmp_acc.LAST) := typ_account_record(r_appointment.app_id, '10001', 'debit',  r_invoice_line."Total Price");
                
                -- Book Credit in Service Revenue Account(10002)
                tmp_acc.EXTEND;
                tmp_acc(tmp_acc.LAST) := typ_account_record(r_appointment.app_id, '10002', 'credit',  r_invoice_line."Total Price");  
                
                FETCH c_invoice INTO r_invoice_line;
            END LOOP; 
            
            -- Confirm Booking
            UPDATE crp_appointment SET app_is_invoiced = 1 WHERE app_id = r_appointment.app_id;
            dbms_output.put_line('Appointment ' ||r_appointment.app_id || ' invoice booked in ERP !' );
            
            FETCH c_appointment INTO r_appointment;
        END LOOP;
        
        RETURN tmp_acc;
        
    END createInvoicesAccountingTable;
    

  PROCEDURE batchInvoices AS
    cnt NUMBER;
    tmp_acc table_accounting := table_accounting();
  BEGIN
        tmp_acc := createInvoicesAccountingTable();
        -- This is where the batch will be sent to the ERP
        cnt := tmp_acc.COUNT;
        IF(cnt > 0) THEN
            FOR i IN tmp_acc.first..tmp_acc.last LOOP
                DBMS_OUTPUT.PUT_LINE(tmp_acc(i).acc_app_id || ' - ' || tmp_acc(i).acc_transaction_type || ' - ' || tmp_acc(i).acc_sap_account || ' - ' || tmp_acc(i).acc_amount);
            END LOOP;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'NO TRANSACTIONS TO BE BOOKED');    
        END IF;
  END batchInvoices;

END PKG_CAREPOINT;
/

EXIT