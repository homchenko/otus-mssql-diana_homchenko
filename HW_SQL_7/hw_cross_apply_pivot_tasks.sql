/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT * FROM
	(SELECT /*CustomerName, */
	FORMAT(InvoiceDate, '01.MM.yyyy', 'ru') AS InvDate, 
	SUM(Quantity) OVER(PARTITION BY I.CustomerID, MONTH(InvoiceDate) ORDER BY MONTH(InvoiceDate)) AS SumQuntity,
	ROW_NUMBER() OVER (PARTITION BY I.CustomerID, MONTH(InvoiceDate) ORDER BY MONTH(InvoiceDate)) AS rn,
	I.CustomerID
	FROM Sales.OrderLines AS OL
	JOIN Sales.Invoices AS I ON I.OrderID = OL.OrderID
	JOIN Sales.Customers AS C ON C.CustomerID = I.CustomerID
	WHERE I.CustomerID BETWEEN 2 AND 6
	AND YEAR(InvoiceDate) = 2015) 
AS Cst
PIVOT(
	SUM(SumQuntity)
FOR Cst.CustomerId IN ([2], [3], [4], [5], [6])) AS PVT_cst
WHERE PVT_cst.rn = 1
ORDER BY InvDate;

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT * FROM (
	SELECT 
		CustomerName,
		DeliveryAddressLine1,
		DeliveryAddressLine2
	FROM Sales.Customers
	WHERE CustomerName LIKE 'Tailspin Toys%') AS Customers
UNPIVOT (Addresses
	FOR AddressType
	IN (DeliveryAddressLine1, DeliveryAddressLine2)) AS UNPVT;

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT * FROM (
	SELECT CountryID,
		CountryName,
		CAST(IsoNumericCode AS nvarchar(3)) AS numCode,
		IsoAlpha3Code
	FROM Application.Countries) AS Cntrs
UNPIVOT (Name
	FOR Code IN (numCode, IsoAlpha3Code)) AS UNPVT_Cntr;
/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT C.CustomerID,
	CustomerName,
	TopOrders.*
FROM Sales.Customers AS C
CROSS APPLY (
	SELECT TOP 2 InvoiceDate, 
		OrderID,
		(UnitPrice * Quantity) AS TotalPrice
	FROM Sales.Invoices as I
	JOIN Sales.InvoiceLines AS IL
	ON IL.InvoiceID = I. InvoiceID
	WHERE I.CustomerID = C.CustomerID /*!!!!*/
	ORDER BY (UnitPrice * Quantity) DESC) AS TopOrders;


