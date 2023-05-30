-- ====================================================================
-- Script : Users.sql
-- Goal   : Create users in Carepoint PDB (Oracle 21c)
-- ====================================================================
SET ECHO ON

-- =============================================================================================
-- Delete existing Roles, Users and Profiles
-- =============================================================================================
DROP USER usr_data CASCADE;
DROP USER usr_app CASCADE;
DROP ROLE rol_data;
DROP ROLE rol_app;
DROP PROFILE pro_global_app;

-- =============================================================================================
-- Global Profile Creation
-- =============================================================================================
CREATE PROFILE pro_global_app LIMIT
	SESSIONS_PER_USER 3
	FAILED_LOGIN_ATTEMPTS 3 
	PASSWORD_LOCK_TIME 1/24
	PASSWORD_LIFE_TIME 180 
	PASSWORD_REUSE_TIME 180 
	PASSWORD_REUSE_MAX UNLIMITED
	PASSWORD_GRACE_TIME 7;

-- =============================================================================================
-- Role Data Creation - Database Object Owner
-- =============================================================================================
CREATE ROLE rol_data;
GRANT CONNECT TO rol_data;
GRANT RESOURCE TO rol_data;
GRANT CREATE VIEW TO rol_data;

-- =============================================================================================
-- Role App Creation - Application User
-- =============================================================================================
CREATE ROLE rol_app;
GRANT CREATE SESSION TO rol_app;
GRANT EXECUTE USR_DATA.PKG_CAREPOINT TO rol_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON view TO rol_app;

-- =============================================================================================
-- User Data Creation
-- =============================================================================================
CREATE USER usr_data
	PROFILE pro_global_app
	IDENTIFIED BY usr_data
	DEFAULT TABLESPACE USERS
	TEMPORARY TABLESPACE TEMP
;
GRANT rol_data TO usr_data;
ALTER USER usr_data quota unlimited ON USERS;

-- =============================================================================================
-- User App Creation
-- =============================================================================================
CREATE USER usr_app
	PROFILE pro_global_app
	IDENTIFIED BY usr_app
;
GRANT rol_app TO usr_app;

EXIT


