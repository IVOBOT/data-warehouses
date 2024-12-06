CREATE DATABASE InsuranceDB;
GO

USE InsuranceDB;
GO

-- Customers
CREATE TABLE CUSTOMER (
    CustomerID UNIQUEIDENTIFIER PRIMARY KEY, -- UUID PK
    FirstName NVARCHAR(30) NOT NULL,         -- 30 characters
    LastName NVARCHAR(30) NOT NULL,          -- 30 characters
    PESEL CHAR(11) NOT NULL,                 -- 11 characters
    DateOfBirth DATE NOT NULL
);
GO

-- Policies
CREATE TABLE POLICY (
    PolicyID UNIQUEIDENTIFIER PRIMARY KEY,    -- UUID PK
    PolicyType NVARCHAR(20) CHECK (PolicyType IN ('housing', 'cars', 'health')), -- ENUM
    PremiumAmount DECIMAL(18, 2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CustomerID UNIQUEIDENTIFIER NOT NULL,     -- FK to CUSTOMER
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);
GO

-- Evaluators
CREATE TABLE EVALUATOR (
    EvaluatorID UNIQUEIDENTIFIER PRIMARY KEY, -- UUID PK
    FirstName NVARCHAR(30) NOT NULL,          -- 30 characters
    LastName NVARCHAR(30) NOT NULL            -- 30 characters
);
GO

-- Claims
CREATE TABLE CLAIM (
    ClaimID UNIQUEIDENTIFIER PRIMARY KEY,     -- UUID PK
    PolicyID UNIQUEIDENTIFIER NOT NULL,       -- FK to POLICY
    ClaimAmount DECIMAL(18, 2) NOT NULL,
    ClaimDate DATE NOT NULL,
    ResultDate DATE NULL,
    Status NVARCHAR(20) CHECK (Status IN ('received', 'pending', 'in evaluation', 'proposed', 'in dispute', 'resolved')), -- ENUM
    Result BIT,                               -- Boolean: 0 = denied, 1 = accepted
    EvaluatorID UNIQUEIDENTIFIER NOT NULL,    -- FK to EVALUATOR
    OfficeID UNIQUEIDENTIFIER NULL,
    SettlementAmount DECIMAL(18, 2) NULL,
    FOREIGN KEY (PolicyID) REFERENCES POLICY(PolicyID),
    FOREIGN KEY (EvaluatorID) REFERENCES EVALUATOR(EvaluatorID)
);
GO