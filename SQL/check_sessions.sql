USE master; 
GO
SELECT 
    spid AS SessionID, 
    hostname AS HostName, 
    program_name AS ProgramName, 
    loginame AS LoginName 
FROM sys.sysprocesses 
WHERE dbid = DB_ID('insurance');