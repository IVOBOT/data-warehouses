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

If (object_id('vETLEmployeeData') is not null) Drop View vETLEmployeeData;
go
CREATE VIEW vETLEmployeeData
AS
SELECT DISTINCT
    e.PESEL AS PESEL,
    e.FirstName AS FirstName,
    e.LastName AS LastName,  -- Removed space from column name
    d.DepartmentID AS DepartmentID,  -- Added Department ID from Departments table
    e.Position AS Position,
	s.SeniorityCategoryID AS SeniorityCategoryID,
    e.Wage AS Wage
FROM dbo.EmployeesTemp e
JOIN dbo.DEPARTMENT d ON e.Department = d.DepartmentName
JOIN dbo.SENIORITY s ON IIF(DATEDIFF(DAY, IIF(e.StartDate IS NULL,'2000-12-31', e.StartDate), e.EndDate) > 365, e.Position + ' - long', e.Position + ' - short') = s.SeniorityCategoryName;

GO

MERGE INTO Evaluator as TT
	USING vETLEmployeeData as ST
		ON TT.PESEL = ST.PESEL AND TT.Position = ST.Position
			WHEN Not Matched
				THEN
					INSERT
					Values (
					ST.PESEL, 
					ST.FirstName,
					ST.LastName,
					ST.DepartmentID,
					ST.Position,
					ST.SeniorityCategoryID,
					1
					)
			WHEN Matched
				THEN
					UPDATE
					SET TT.isCurrent = 0,
					TT.SeniorityCategoryID = ST.SeniorityCategoryID
			WHEN Not Matched By Source
				Then
					DELETE
			;
Drop View vETLEmployeeData;

SELECT * FROM EVALUATOR

--DELETE FROM EVALUATOR