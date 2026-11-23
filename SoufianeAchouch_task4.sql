-- =========================================================
-- Practical Assignment 4


IF @@SERVERNAME LIKE 'MSQLDBLAB%'
BEGIN
    PRINT 'Stopped: shared school server. Run this on your own local copy of CRA.';
    SET NOEXEC ON;   -- skips everything below; run SET NOEXEC OFF; to undo
END
GO

USE CRA;
GO


-- ---------------------------------------------------------
-- 1.
-- ---------------------------------------------------------
IF COL_LENGTH('dbo.Subscriber', 'discount') IS NULL
    ALTER TABLE dbo.Subscriber
    ADD discount DECIMAL(3,2) NOT NULL
        CONSTRAINT DF_Subscriber_discount DEFAULT 0.00;
GO


-- ---------------------------------------------------------
-- 2. 
-- ---------------------------------------------------------
IF COL_LENGTH('dbo.Person', 'email') IS NULL
    ALTER TABLE dbo.Person
    ADD email VARCHAR(50) NULL;
GO


-- ---------------------------------------------------------
-- 3. 
-- ---------------------------------------------------------
IF OBJECT_ID('dbo.Domain', 'U') IS NULL
    CREATE TABLE dbo.[Domain] (
        domainID    INT IDENTITY(1,1) PRIMARY KEY,
        domainName  VARCHAR(15)
    );
GO


-- ---------------------------------------------------------
-- 4. 
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.[Domain])
    INSERT INTO dbo.[Domain] (domainName)
    VALUES ('gmail.com'),
           ('yahoo.com'),
           ('hotmail.com'),
           ('eif.viko.lt');
GO


-- ---------------------------------------------------------
-- 5. 
-- ---------------------------------------------------------
UPDATE p
SET p.email = LOWER(p.firstName) + '.' + LOWER(p.lastName) + '@' + d.domainName
FROM dbo.Person p
CROSS APPLY (
    SELECT TOP (1) dm.domainName
    FROM dbo.[Domain] dm
    ORDER BY CHECKSUM(NEWID(), p.personID)
) AS d;
GO


-- ---------------------------------------------------------
-- 6. 
-- ---------------------------------------------------------
IF OBJECT_ID('dbo.MobilePhone', 'U') IS NULL
    CREATE TABLE dbo.MobilePhone (
        mobTelID      INT IDENTITY(1,1) PRIMARY KEY,
        manufacturer  VARCHAR(15),
        model         VARCHAR(30),
        price         FLOAT,
        monthlyPrice  FLOAT
    );
GO


-- ---------------------------------------------------------
-- 7. 
-- ---------------------------------------------------------
IF COL_LENGTH('dbo.Subscriber', 'mobTelID') IS NULL
    ALTER TABLE dbo.Subscriber
    ADD mobTelID INT NULL;
GO


-- ---------------------------------------------------------
-- 8. Foreign key Subscriber.mobTelID -> MobilePhone.mobTelID
-- ---------------------------------------------------------
IF OBJECT_ID('dbo.FK_Subscriber_MobilePhone', 'F') IS NULL
    ALTER TABLE dbo.Subscriber
    ADD CONSTRAINT FK_Subscriber_MobilePhone
        FOREIGN KEY (mobTelID) REFERENCES dbo.MobilePhone (mobTelID);
GO


-- ---------------------------------------------------------
-- 9. 
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.MobilePhone)
    BULK INSERT dbo.MobilePhone
    FROM 'C:\Temp\mobile-phones.txt'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0a'
    );
GO


-- ---------------------------------------------------------
-- 10. 
-- ---------------------------------------------------------
UPDATE s
SET s.mobTelID = m.mobTelID
FROM dbo.Subscriber s
CROSS APPLY (
    SELECT TOP (1) mp.mobTelID
    FROM dbo.MobilePhone mp
    ORDER BY CHECKSUM(NEWID(), s.subscriberID)
) AS m
WHERE s.contractEndDate IS NULL;
GO



