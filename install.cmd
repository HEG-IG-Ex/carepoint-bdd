@ECHO OFF

REM Fichier		: Installation.cmd
REM Objet		: Création de la BDD Carepoint

SET LOGDIR=.\Logs
SET USERNAME=sys
SET /p SYS_DBA_PASSWORD=Enter your SYSDBA password:
SET DATABASE_NAME=localhost:1521/carepoint_pdb
SET SYSDBA_CONNECTION_STRING=%username%/%sys_dba_password%@%database_name% as sysdba
SET USR_DATA_CONNECTION_STRING=usr_data/usr_data@%database_name%

REM Create log directory if it doesn't exist
IF NOT EXIST %LOGDIR% MKDIR %LOGDIR%

ECHO Executing user creation script...
SQLPLUS %SYSDBA_CONNECTION_STRING% @%~dp0\users.sql %~dp0 >> %LOGDIR%\users.log

ECHO Executing drop script...
SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\drop.sql %~dp0 >> %LOGDIR%\drop.log

ECHO Executing tables script...
SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\tables.sql %~dp0 >> %LOGDIR%\tables.log

ECHO Executing views script...
SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\views.sql %~dp0 >> %LOGDIR%\views.log

ECHO Executing packages script...
SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\package.sql %~dp0 >> %LOGDIR%\package.log

ECHO Executing triggers script...
SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\triggers.sql %~dp0 >> %LOGDIR%\triggers.log

ECHO Executing insert script...
SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\insert.sql %~dp0 >> %LOGDIR%\insert.log

REM ECHO Executing privileges script...
REM SQLPLUS %USR_DATA_CONNECTION_STRING% @%~dp0\privileges.sql %~dp0 >> %LOGDIR%\privileges.log

ECHO Executing synonyms script...
SQLPLUS %SYSDBA_CONNECTION_STRING% @%~dp0\synonyms.sql %~dp0 >> %LOGDIR%\synonyms.log


REM Turn off echoing of commands for the rest of the script
ECHO OFF

PAUSE
