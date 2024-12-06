USE InsuranceDB;
GO

-- Insert new data

BULK INSERT CUSTOMER
FROM '\data\customers_additional.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

BULK INSERT POLICY
FROM '\data\policies_additional.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

BULK INSERT CLAIM
FROM '\data\claims_additional.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

BULK INSERT EVALUATOR
FROM '\data\evaluators_additional.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

-- Update existing data

DROP TABLE IF EXISTS #TempCustomer;

CREATE TABLE #TempCustomer (
    CustomerID UNIQUEIDENTIFIER,
    FirstName NVARCHAR(30),
    LastName NVARCHAR(30),
    PESEL CHAR(11),
    DateOfBirth DATE
);

BULK INSERT #TempCustomer
FROM '\data\customers_updates.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

MERGE INTO CUSTOMER AS target
USING #TempCustomer AS source
ON target.CustomerID = source.CustomerID
WHEN MATCHED THEN
    UPDATE SET 
        FirstName = source.FirstName,
        LastName = source.LastName,
        PESEL = source.PESEL,
        DateOfBirth = source.DateOfBirth
WHEN NOT MATCHED THEN
    INSERT (CustomerID, FirstName, LastName, PESEL, DateOfBirth)
    VALUES (source.CustomerID, source.FirstName, source.LastName, source.PESEL, source.DateOfBirth);

DROP TABLE #TempCustomer;
GO

/* DROP TABLE IF EXISTS #TempPolicy;

CREATE TABLE #TempPolicy (
    PolicyID UNIQUEIDENTIFIER,
    PolicyType NVARCHAR(20),
    PremiumAmount DECIMAL(18, 2),
    StartDate DATE,
    EndDate DATE,
    CustomerID UNIQUEIDENTIFIER
);

BULK INSERT #TempPolicy
FROM '\data\policies_updates.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

MERGE INTO POLICY AS target
USING #TempPolicy AS source
ON target.PolicyID = source.PolicyID
WHEN MATCHED THEN
    UPDATE SET 
        PolicyType = source.PolicyType,
        PremiumAmount = source.PremiumAmount,
        StartDate = source.StartDate,
        EndDate = source.EndDate,
        CustomerID = source.CustomerID
WHEN NOT MATCHED THEN
    INSERT (PolicyID, PolicyType, PremiumAmount, StartDate, EndDate, CustomerID)
    VALUES (source.PolicyID, source.PolicyType, source.PremiumAmount, source.StartDate, source.EndDate, source.CustomerID);

DROP TABLE #TempPolicy;
GO */

/* DROP TABLE IF EXISTS #TempEvaluator;

CREATE TABLE #TempEvaluator (
    EvaluatorID UNIQUEIDENTIFIER,
    FirstName NVARCHAR(30),
    LastName NVARCHAR(30)
);

BULK INSERT #TempEvaluator
FROM '\data\evaluators_updates.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

MERGE INTO EVALUATOR AS target
USING #TempEvaluator AS source
ON target.EvaluatorID = source.EvaluatorID
WHEN MATCHED THEN
    UPDATE SET 
        FirstName = source.FirstName,
        LastName = source.LastName
WHEN NOT MATCHED THEN
    INSERT (EvaluatorID, FirstName, LastName)
    VALUES (source.EvaluatorID, source.FirstName, source.LastName);

DROP TABLE #TempEvaluator;
GO */

DROP TABLE IF EXISTS #TempClaim;

CREATE TABLE #TempClaim (
    ClaimID UNIQUEIDENTIFIER,
    PolicyID UNIQUEIDENTIFIER,
    ClaimAmount DECIMAL(18, 2),
    ClaimDate DATE,
    ResultDate DATE,
    Status NVARCHAR(20),
    Result BIT,
    EvaluatorID UNIQUEIDENTIFIER,
    OfficeID UNIQUEIDENTIFIER,
    SettlementAmount DECIMAL(18, 2)
);

BULK INSERT #TempClaim
FROM '\data\claims_updates.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

MERGE INTO CLAIM AS target
USING #TempClaim AS source
ON target.ClaimID = source.ClaimID
WHEN MATCHED THEN
    UPDATE SET 
        PolicyID = source.PolicyID,
        ClaimAmount = source.ClaimAmount,
        ClaimDate = source.ClaimDate,
        ResultDate = source.ResultDate,
        Status = source.Status,
        Result = source.Result,
        EvaluatorID = source.EvaluatorID,
        OfficeID = source.OfficeID,
        SettlementAmount = source.SettlementAmount
WHEN NOT MATCHED THEN
    INSERT (ClaimID, PolicyID, ClaimAmount, ClaimDate, ResultDate, Status, Result, EvaluatorID, OfficeID, SettlementAmount)
    VALUES (source.ClaimID, source.PolicyID, source.ClaimAmount, source.ClaimDate, source.ResultDate, source.Status, source.Result, source.EvaluatorID, source.OfficeID, source.SettlementAmount);

DROP TABLE #TempClaim;
GO
