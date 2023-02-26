/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT PersonId, FullName
FROM Application.People AS P
WHERE P.IsSalesperson = 1
	AND NOT EXISTS (
	SELECT ContactPersonID 
	FROM Sales.Invoices AS S
	WHERE P.PersonID = S.ContactPersonID
	AND S.InvoiceDate = '2015-07-05');

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT StockItemID, 
	StockItemName, 
	UnitPrice,
	(SELECT MIN(UnitPrice) 
	FROM Warehouse.StockItems) AS MinPrice
FROM Warehouse.StockItems AS S
WHERE UnitPrice = (
	SELECT MIN(UnitPrice) 
	FROM Warehouse.StockItems);

	
	SELECT StockItemID, 
	StockItemName, 
	UnitPrice,
	(SELECT MIN(UnitPrice) 
	FROM Warehouse.StockItems AS St
	WHERE St.Brand = 'Northwind') AS MinPrice
FROM Warehouse.StockItems AS S
WHERE UnitPrice < (
	SELECT MIN(UnitPrice) 
	FROM Warehouse.StockItems AS St
	WHERE St.Brand = 'Northwind');


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT TOP 5
CustomerID, 
CustomerName,
	(SELECT MAX(TransactionAmount)
	FROM Sales.CustomerTransactions AS CT
	WHERE CT.CustomerID = C.CustomerID) AS TAmount
FROM Sales.Customers AS C
ORDER BY TAmount DESC


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).

-Sales.CustomerTransactions.CustomerID
-Sales.Customers.DeliveryCityID
-Application.Cities.CityID
-Sales.Invoices.PackedByPersonID
*/

WITH CustomerTransactions_CTE AS
(
	SELECT TOP 3 
		CustomerId 
	FROM Sales.CustomerTransactions
	ORDER BY TransactionAmount DESC
),
Customers_CTE AS
(
	SELECT DeliveryCityID, CustomerName
	FROM Sales.Customers AS C
	JOIN CustomerTransactions_CTE AS CT
	ON C.CustomerID = CT.CustomerID
),
Cities_CTE AS
(
	SELECT CityName, CityID
	FROM Application.Cities AS C
	JOIN Customers_CTE AS CC
	ON C.CityID = CC.DeliveryCityID
)
SELECT CityName, CityID, CustomerName
FROM Customers_CTE
JOIN Cities_CTE
ON Customers_CTE.DeliveryCityID = Cities_CTE.CityID
ORDER BY CityName;

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
