USE insurance
GO

IF (OBJECT_ID('dbo.EmployeesTemp') IS NOT NULL) 
    DROP TABLE dbo.EmployeesTemp;

CREATE TABLE dbo.EmployeesTemp (
    ID VARCHAR(100),
    PESEL VARCHAR(100),
    FirstName VARCHAR(100),
    LastName VARCHAR(100),  -- Removed space from column name
    DateOfBirth DATE,
    Department VARCHAR(100),
    Position VARCHAR(100),
    StartDate DATE,         -- Changed column name to StartDate
    EndDate DATE,           -- Changed column name to EndDate
    Wage INT     -- Changed to DECIMAL(18, 2) to handle large wage values
);

BULK INSERT dbo.EmployeesTemp
    FROM 'C:\Users\micha\projects\hurtownie\data-warehouses\MSSQL\scripts\data\employees_first.csv'
    WITH
    (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '0x0a',   --Use to shift the control to next row
    TABLOCK
    )

--SELECT * FROM dbo.BookstoresTemp;

If (object_id('vETLSeniorityData') is not null) Drop View vETLSeniorityData;
go
CREATE VIEW vETLSeniorityData
AS
SELECT DISTINCT
	IIF(DATEDIFF(day, IIF(StartDate IS NULL,'2000-12-31', StartDate), EndDate) > 365, Position + ' - long', Position + ' - short') as seniority
FROM dbo.EmployeesTemp;
go

MERGE INTO Seniority as TT
	USING vETLSeniorityData as ST
		ON TT.SeniorityCategoryName = ST.seniority
			WHEN Not Matched
				THEN
					INSERT
					Values (
					ST.seniority
					)
			WHEN Not Matched By Source
				Then
					DELETE
			;
Drop View vETLSeniorityData;

SELECT * FROM SENIORITY;