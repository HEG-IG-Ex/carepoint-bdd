SET ECHO ON

BEGIN
    FOR view_rec IN (SELECT view_name, owner FROM all_views WHERE owner = 'USR_DATA') LOOP
        -- Generate a synonym name using a portion of the view name
        -- For example, if the view name is "VW_DOCTORS", the synonym name will be "DOCTORS"
        -- then it grants access to the view to the application role
        DECLARE
            synonym_name VARCHAR2(100) :=  REPLACE(view_rec.view_name, 'VW_', '');
        BEGIN
            -- Create the synonym
            EXECUTE IMMEDIATE 'CREATE SYNONYM USR_APP.' || synonym_name || ' FOR ' || view_rec.owner || '.' || view_rec.view_name;
            DBMS_OUTPUT.PUT_LINE('Synonym created: USR_APP.' || synonym_name);

            -- Grant privilege to Role App
            EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || synonym_name || ' TO rol_app';

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error creating synonym for view: ' || view_rec.view_name || ', Error: ' || SQLERRM);
        END;
    END LOOP;
    COMMIT;
END;
/

EXIT