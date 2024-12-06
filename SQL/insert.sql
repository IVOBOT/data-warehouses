USE insurance;
GO

-- Tabela CATEGORY
INSERT INTO CATEGORY (CategoryName) VALUES
('Health Insurance'),
('Car Insurance'),
('Home Insurance'),
('Life Insurance');

-- Tabela SENIORITY
INSERT INTO SENIORITY (SeniorityCategoryName) VALUES
('Junior Evaluator'),
('Mid-level Evaluator'),
('Senior Evaluator'),
('Lead Evaluator');

-- Tabela DEPARTMENT
INSERT INTO DEPARTMENT (DepartmentName) VALUES
('Claims Department'),
('Risk Assessment Department'),
('Customer Support Department'),
('Fraud Investigation Department');

-- Tabela EVALUATOR
INSERT INTO EVALUATOR (PESEL, FirstName, LastName, DepartmentID, Position, SeniorityCategoryID, IsCurrent) VALUES
('90010112345', 'Anna', 'Nowak', 1, 'Claims Specialist', 1, 1),
('89020254321', 'Jan', 'Kowalski', 2, 'Risk Analyst', 2, 1),
('85030398765', 'Ewa', 'Wiśniewska', 3, 'Customer Service Agent', 3, 0),
('87040487654', 'Piotr', 'Zieliński', 4, 'Fraud Investigator', 4, 1),
('92050567890', 'Katarzyna', 'Lewandowska', 1, 'Claims Specialist', 2, 1),
('88121234567', 'Tomasz', 'Wójcik', 2, 'Risk Analyst', 3, 1),
('91080876543', 'Marta', 'Kaczmarek', 3, 'Customer Service Agent', 1, 1),
('93060612345', 'Rafał', 'Bąk', 4, 'Fraud Investigator', 4, 1);

-- Tabela JUNK
INSERT INTO JUNK (IsAccepted) VALUES
('Yes'),
('No');

-- Tabela DATE
DECLARE @date DATE = '2024-01-01';

WHILE @date <= '2024-12-31'
BEGIN
    INSERT INTO DATE (Day, MonthNumber, MonthName, Quarter, Year, Date)
    VALUES
    (DAY(@date), MONTH(@date), DATENAME(MONTH, @date), 
     CASE 
        WHEN MONTH(@date) BETWEEN 1 AND 3 THEN 1
        WHEN MONTH(@date) BETWEEN 4 AND 6 THEN 2
        WHEN MONTH(@date) BETWEEN 7 AND 9 THEN 3
        ELSE 4
     END, 
     YEAR(@date), @date);

    SET @date = DATEADD(DAY, 1, @date);
END;

-- Tabela CLAIM
INSERT INTO CLAIM (ResultDateID, EvaluatorID, CategoryID, ProcessingTime, ClaimAmount, SettlementAmount, JunkID) VALUES
(1, 1, 1, 6, 2000.00, 1800.00, 1),
(90, 2, 2, 3.0, 5000.00, 4500.00, 1),
(180, 3, 3, 21, 3000.00, 2800.00, 2),
(270, 4, 4, 2.0, 10000.00, 9500.00, 3),
(30, 5, 1, 35, 4000.00, 3800.00, 2),
(120, 6, 2, 4.0, 7000.00, 6700.00, 1),
(210, 7, 3, 46, 2500.00, 2300.00, 3),
(330, 8, 4, 5.0, 12000.00, 11800.00, 1),
(45, 2, 1, 20, 3000.00, 2900.00, 1),
(150, 5, 4, 8, 11000.00, 10500.00, 3);