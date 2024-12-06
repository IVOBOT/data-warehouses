USE InsuranceDB;
GO

DECLARE @directory NVARCHAR(MAX)

SET @directory = 'C:\Users\micha\projects\hurtownie\data-warehouses\MSSQL\scripts'

DECLARE @filePath NVARCHAR(MAX);

SET @filePath = @directory + '\data\customers_first.csv'; -- Konkatenacja œcie¿ki

BULK INSERT CUSTOMER
FROM 'C:\Users\micha\projects\hurtownie\data-warehouses\MSSQL\scripts\data\customers_first.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

BULK INSERT POLICY
FROM 'C:\Users\micha\projects\hurtownie\data-warehouses\MSSQL\scripts\data\policies_first.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

BULK INSERT CLAIM
FROM 'C:\Users\micha\projects\hurtownie\data-warehouses\MSSQL\scripts\data\claims_first.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO

BULK INSERT EVALUATOR
FROM 'C:\Users\micha\projects\hurtownie\data-warehouses\MSSQL\scripts\data\evaluators_first.csv'
WITH
(
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
GO