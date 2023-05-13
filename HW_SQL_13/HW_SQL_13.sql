--HW_SQL_13
--Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.

--1. Написать функцию возвращающую Клиента с наибольшей суммой покупки.
USE WideWorldImporters
GO

CREATE OR ALTER FUNCTION Sales.GetClientWhthMaxPurchase()
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT TOP 1
		Cust.CustomerID
		, Cust.CustomerName
		, InvL.Quantity * InvL.UnitPrice AS MaxPurch
	FROM Sales.Customers AS Cust
	JOIN Sales.Invoices AS Inv
	ON Inv.CustomerID = Cust.CustomerID
	JOIN Sales.InvoiceLines AS InvL
	ON InvL.InvoiceID = Inv.InvoiceID
	GROUP BY Cust.CustomerID, Cust.CustomerName, (InvL.Quantity * InvL.UnitPrice)
	ORDER BY MaxPurch DESC
);  
GO

SELECT * FROM Sales.GetClientWhthMaxPurchase()
GO

--2. Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.

/*Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines*/

CREATE OR ALTER PROCEDURE dbo.usp_GetMaxPurch
	@CustomerId INT,
	@SumPurch decimal(18, 2) OUTPUT
AS
(
	SELECT @SumPurch = (InvL.Quantity * InvL.UnitPrice)
	FROM Sales.Customers AS Cust
	JOIN Sales.Invoices AS Inv
	ON Inv.CustomerID = Cust.CustomerID
	JOIN Sales.InvoiceLines AS InvL
	ON InvL.InvoiceID = Inv.InvoiceID
	WHERE Cust.CustomerID = @CustomerId
)
GO

DECLARE @SumPurchRes decimal(18, 2)
exec dbo.usp_GetMaxPurch 1, @SumPurchRes OUTPUT
SELECT @SumPurchRes

--3. Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.

CREATE OR ALTER FUNCTION Sales.uf_GetName(@CustId INT)
RETURNS nvarchar(100)
AS  
BEGIN
	DECLARE @name nvarchar(100)
	SELECT 
		@name = Cust.CustomerID
	FROM Sales.Customers AS Cust
	JOIN Sales.Invoices AS Inv
	ON Inv.CustomerID = Cust.CustomerID
	JOIN Sales.InvoiceLines AS InvL
	ON InvL.InvoiceID = Inv.InvoiceID
	WHERE Cust.CustomerID = @CustId
	RETURN @name
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetName
	@CustomerId INT,
	@CustName nvarchar(100) OUTPUT
AS
(
	SELECT @CustName = Cust.CustomerID
	FROM Sales.Customers AS Cust
	JOIN Sales.Invoices AS Inv
	ON Inv.CustomerID = Cust.CustomerID
	JOIN Sales.InvoiceLines AS InvL
	ON InvL.InvoiceID = Inv.InvoiceID
	WHERE Cust.CustomerID = @CustomerId
)
GO

SET STATISTICS IO, TIME ON

SELECT Sales.uf_GetName(2)

DECLARE @res nvarchar(100)
EXEC dbo.usp_GetName 2, @res OUTPUT
SELECT @res 

--4. Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

CREATE OR ALTER FUNCTION Sales.SomeF()
RETURNS TABLE  
AS  
RETURN   
(
	SELECT c.PhoneNumber + '  ***TestOfFunc' as TEST
	FROM Sales.Customers AS c
)
GO

SELECT TEST
	, c.CustomerName
FROM Sales.Customers AS c
CROSS APPLY Sales.SomeF()


