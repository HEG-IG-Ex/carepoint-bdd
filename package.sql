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

    FUNCTION getNextAvailabilityForDoc (i_doc_id INTEGER) RETURN SYS_REFCURSOR AS
        c_availability SYS_REFCURSOR; 
    BEGIN
        OPEN c_availability FOR SELECT DT FROM (SELECT SYSDATE + (level - 1) AS DT FROM dual CONNECT BY SYSDATE + (level - 1) <= ADD_MONTHS(SYSDATE, 1))
        LEFT OUTER JOIN (SELECT APP_APTN_DATE FROM CRP_APPOINTMENT WHERE APP_DOC_ID = i_doc_id) ON APP_APTN_DATE = DT ORDER BY DT;
        IF c_availability%NOTFOUND THEN
            CLOSE c_availability;
            RAISE_APPLICATION_ERROR(-20002, 'Doctor doesn''t have any availability for the next month');
        END IF;
        RETURN c_availability;
    END getNextAvailabilityForDoc;

    FUNCTION getNextAvailabilityForSpe (i_spe_id INTEGER) RETURN SYS_REFCURSOR AS
        c_availability SYS_REFCURSOR; 
    BEGIN
        OPEN c_availability FOR SELECT DT FROM (SELECT SYSDATE + (level - 1) AS DT FROM dual CONNECT BY SYSDATE + (level - 1) <= ADD_MONTHS(SYSDATE, 1))
        LEFT OUTER JOIN (SELECT APP_APTN_DATE FROM CRP_APPOINTMENT WHERE APP_DOC_ID IN (SELECT DOC_PER_ID FROM CRP_DOC WHERE DOC_SPE_ID = i_spe_id)) ON APP_APTN_DATE = DT ORDER BY DT;
        IF c_availability%NOTFOUND THEN
            CLOSE c_availability;
            RAISE_APPLICATION_ERROR(-20003, 'No Doctor for this Specialty have any availability for the next month');
        END IF;
        RETURN c_availability;
    END getNextAvailabilityForSpe;


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