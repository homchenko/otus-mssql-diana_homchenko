/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

SELECT TOP 5 
	SupplierID
	,SupplierName
	,SupplierCategoryID
	,PrimaryContactPersonID
	,AlternateContactPersonID
	,DeliveryMethodID
	,DeliveryCityID
	,PostalCityID
	,SupplierReference
	,BankAccountName
	,BankAccountBranch
	,BankAccountCode
	,BankAccountNumber
	,BankInternationalCode
	,PaymentDays
	,InternalComments
	,PhoneNumber
	,FaxNumber
	,WebsiteURL
	,DeliveryAddressLine1
	,DeliveryAddressLine2
	,DeliveryPostalCode
	,DeliveryLocation
	,PostalAddressLine1
	,PostalAddressLine2
	,PostalPostalCode
	,LastEditedBy
	,ValidFrom
	,ValidTo
INTO Purchasing.Suppliers_new
FROM Purchasing.Suppliers
ORDER BY SupplierID DESC;

SELECT * 
FROM Purchasing.Suppliers_new
ORDER BY SupplierID;

--drop table if exists Purchasing.Suppliers_new;

INSERT INTO Purchasing.Suppliers_new
SELECT --TOP 5
	SupplierID
	,SupplierName
	,SupplierCategoryID
	,PrimaryContactPersonID
	,AlternateContactPersonID
	,DeliveryMethodID
	,DeliveryCityID
	,PostalCityID
	,SupplierReference
	,BankAccountName
	,BankAccountBranch
	,BankAccountCode
	,BankAccountNumber
	,BankInternationalCode
	,PaymentDays
	,InternalComments
	,PhoneNumber
	,FaxNumber
	,WebsiteURL
	,DeliveryAddressLine1
	,DeliveryAddressLine2
	,DeliveryPostalCode
	,DeliveryLocation
	,PostalAddressLine1
	,PostalAddressLine2
	,PostalPostalCode
	,LastEditedBy
	,ValidFrom
	,ValidTo
FROM Purchasing.Suppliers
WHERE Purchasing.Suppliers.SupplierID > 10
--ORDER BY SupplierID ASC;

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Purchasing.Suppliers_new
WHERE Purchasing.Suppliers_new.SupplierID = 9;

SELECT * 
FROM Purchasing.Suppliers_new
ORDER BY SupplierID;
/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Purchasing.Suppliers_new
SET SupplierName = 'TEST_NAME'
WHERE SupplierID = 13;

SELECT * 
FROM Purchasing.Suppliers_new
ORDER BY SupplierID;

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Purchasing.Suppliers_new AS target
USING Purchasing.Suppliers AS S
ON target.SupplierName = S.SupplierName
WHEN MATCHED
	THEN UPDATE SET SupplierName = 'TEST_name'--S.SupplierName
	,SupplierCategoryID = S.SupplierCategoryID
	,PrimaryContactPersonID = S.PrimaryContactPersonID
	,AlternateContactPersonID = S.AlternateContactPersonID
	,DeliveryMethodID = S.DeliveryMethodID
WHEN NOT MATCHED
	THEN INSERT (SupplierID
	,SupplierName
	,SupplierCategoryID
	,PrimaryContactPersonID
	,AlternateContactPersonID
	,DeliveryMethodID
	,DeliveryCityID
	,PostalCityID
	,SupplierReference
	,BankAccountName
	,BankAccountBranch
	,BankAccountCode
	,BankAccountNumber
	,BankInternationalCode
	,PaymentDays
	,InternalComments
	,PhoneNumber
	,FaxNumber
	,WebsiteURL
	,DeliveryAddressLine1
	,DeliveryAddressLine2
	,DeliveryPostalCode
	,DeliveryLocation
	,PostalAddressLine1
	,PostalAddressLine2
	,PostalPostalCode
	,LastEditedBy
	,ValidFrom
	,ValidTo)
	VALUES (S.SupplierID
	,S.SupplierName
	,S.SupplierCategoryID
	,S.PrimaryContactPersonID
	,S.AlternateContactPersonID
	,S.DeliveryMethodID
	,S.DeliveryCityID
	,S.PostalCityID
	,S.SupplierReference
	,S.BankAccountName
	,S.BankAccountBranch
	,S.BankAccountCode
	,S.BankAccountNumber
	,S.BankInternationalCode
	,S.PaymentDays
	,S.InternalComments
	,S.PhoneNumber
	,S.FaxNumber
	,S.WebsiteURL
	,S.DeliveryAddressLine1
	,S.DeliveryAddressLine2
	,S.DeliveryPostalCode
	,S.DeliveryLocation
	,S.PostalAddressLine1
	,S.PostalAddressLine2
	,S.PostalPostalCode
	,S.LastEditedBy
	,S.ValidFrom
	,S.ValidTo);

SELECT * 
FROM Purchasing.Suppliers_new
ORDER BY SupplierID;
/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

--//////--

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Purchasing.Suppliers_new" out  "D:\Program Files\Microsoft SQL Server\MSSQL16.SQLSERVER\MSSQL\Projects_SQL\HW_SQL_9\testLines.txt" -T -w -t, -S HL-16\SQLSERVER'

CREATE TABLE [Purchasing].[test](
	[LineID] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Num] [int] NULL
 CONSTRAINT [PK_Sales_InvoiceLines_BulkDemo] PRIMARY KEY CLUSTERED 
(
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]

SELECT * 
FROM Purchasing.test
--drop table if exists Purchasing.test;

BULK INSERT [WideWorldImporters].[Purchasing].[test]
FROM "D:\Program Files\Microsoft SQL Server\MSSQL16.SQLSERVER\MSSQL\Projects_SQL\HW_SQL_9\testLines.txt"
WITH 
(
	BATCHSIZE = 3, 
	DATAFILETYPE = 'widechar',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR ='\n',
	KEEPNULLS,
	TABLOCK        
);
