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
	
If (object_id('vETLEmployeeData') is not null) Drop View vETLEmployeeData;
go
CREATE VIEW vETLEmployeeData
AS
SELECT DISTINCT
	e.ID AS ID,
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

If (object_id('vETLClaimNoData') is not null) Drop View vETLClaimNoData;
go
CREATE VIEW vETLClaimNoData
AS
SELECT DISTINCT
	ClaimID as ClaimNo
FROM InsuranceDB.dbo.CLAIM
WHERE Status = 'resolved'
go

MERGE INTO CLAIM_NO as TT
	USING vETLClaimNoData as ST
		ON TT.ClaimNo = ST.ClaimNo
			WHEN Not Matched
				THEN
					INSERT
					Values (
					ST.ClaimNo
					)
			WHEN Not Matched By Source
				Then
					DELETE
			;

SELECT * FROM CLAIM_NO;

Drop View vETLClaimNoData;

If (object_id('vETLClaimData') is not null) Drop View vETLClaimData;
go
CREATE VIEW vETLClaimData
AS
SELECT
	d.ID as ResultDateID,
	e.EvaluatorID as EvaluatorID,
	cat.CategoryID as CategoryID,
	cn.ClaimNoID as ClaimNoID,
	IIF(c.ResultDate IS NULL, NULL, DATEDIFF(DAY, c.ClaimDate, c.ResultDate)) as ProcessingTime,
	c.ClaimAmount as ClaimAmount,
	IIF(c.SettlementAmount IS NULL, NULL, c.SettlementAmount) as SetllementAmount,
	j.JunkID as JunkID
FROM InsuranceDB.dbo.CLAIM c
JOIN insurance.dbo.DATE d on c.ResultDate = d.Date
JOIN Insurance.dbo.vETLEmployeeData emp ON c.EvaluatorID = emp.ID
JOIN dbo.EVALUATOR e ON e.PESEL = emp.PESEL AND e.Position = emp.Position
JOIN InsuranceDB.dbo.POLICY p ON p.PolicyID = c.PolicyID
JOIN dbo.CATEGORY cat ON p.PolicyType = cat.CategoryName
JOIN dbo.JUNK j ON j.IsAccepted = IIF(c.Result = '1', 'yes', 'no')
JOIN dbo.CLAIM_NO cn ON CAST(c.ClaimID AS varchar(255)) = CAST(cn.ClaimNo AS varchar(255))
WHERE c.Status = 'resolved'
;

GO

SELECT * FROM dbo.vETLClaimData
ORDER BY ClaimNoID;

MERGE INTO Claim as TT
	USING vETLClaimData as ST
		ON TT.ClaimNoID = ST.ClaimNoID
			WHEN Not Matched
				THEN
					INSERT
					Values (
					ST.ResultDateID, 
					ST.EvaluatorID,
					ST.CategoryID,
					ST.ClaimNoID,
					ST.ProcessingTime,
					ST.ClaimAmount,
					ST.SetllementAmount,
					ST.JunkID
					)
			WHEN Not Matched By Source
				Then
					DELETE
			;

SELECT * FROM EVALUATOR;
SELECT * FROM CLAIM;