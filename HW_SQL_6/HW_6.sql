/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

SELECT CustomerTransactionId,
	CustomerId,
	TransactionDate,
	TaxAmount,
	(
		SELECT SUM(TaxAmount)
		FROM Sales.CustomerTransactions AS CT_sub
		WHERE CT_sub.CustomerTransactionID = CT_sub.CustomerTransactionID
		AND MONTH(CT_sub.TransactionDate) <= MONTH(CT.TransactionDate)
	) AS SumTaxAmount
FROM Sales.CustomerTransactions AS CT
WHERE YEAR(TransactionDate) > 2014
AND TaxAmount > 0
ORDER BY CustomerId, TransactionDate, SumTaxAmount;

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

SELECT CustomerTransactionId,
	CustomerId,
	TransactionDate, 
	SUM(TaxAmount) OVER(PARTITION BY YEAR(TransactionDate), MONTH(TransactionDate)) AS TaxAmountMonthly,
	SUM(TaxAmount) OVER(ORDER BY YEAR(TransactionDate), MONTH(TransactionDate)) AS SumTaxAmount
FROM Sales.CustomerTransactions AS CT
WHERE YEAR(TransactionDate) > 2014
AND TaxAmount > 0
ORDER BY CustomerId, TransactionDate, SumTaxAmount;

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

SELECT * FROM
	(SELECT SI.StockItemID,
		StockItemName,
		InvoiceDate,
		MONTH(InvoiceDate) AS SalesMonth,
		SUM(Quantity) OVER(PARTITION BY MONTH(InvoiceDate), StockItemName) AS SumQ,
		ROW_NUMBER() OVER(PARTITION BY MONTH(InvoiceDate) ORDER BY Quantity DESC) AS rn_quantity
	FROM Warehouse.StockItems AS SI
	JOIN Sales.InvoiceLines AS IL
	ON IL.StockItemID = SI.StockItemID
	JOIN Sales.Invoices AS I
	ON I.InvoiceID = IL.InvoiceID
	WHERE YEAR(InvoiceDate) = 2016) AS Populars
WHERE Populars.rn_quantity < 3
ORDER BY SalesMonth, Populars.rn_quantity ASC;

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
1 пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
2 посчитайте общее количество товаров и выведете полем в этом же запросе
3 посчитайте общее количество товаров в зависимости от первой буквы названия товара
4 отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
5 предыдущий ид товара с тем же порядком отображения (по имени)
6 названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
7 сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT StockItemID,
	StockItemName,
	Brand,
	UnitPrice,
	RANK() OVER(PARTITION BY StockItemName ORDER BY StockItemName) AS rn_StockItemName, --1 ???
	SUM(QuantityPerOuter) OVER() AS TotalQuantity, --2
	SUM(QuantityPerOuter) OVER(ORDER BY StockItemName) AS ItemQuantity, --3 ???
	LEAD(StockItemID) OVER(ORDER BY StockItemName) AS LeadId, --4
	LAG(StockItemID) OVER(ORDER BY StockItemName) AS LagId, --5
	LAG(StockItemName, 2, 'No items') OVER(ORDER BY StockItemId) AS LagName, --6
	NTILE(30) OVER (ORDER BY TypicalWeightPerUnit) AS weight --7
FROM Warehouse.StockItems AS SI
ORDER BY StockItemID;


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
SELECT * FROM
	(SELECT PersonID,
		FullName,
		C.CustomerID,
		C.CustomerName,
		TransactionAmount,
		TransactionDate,
		ROW_NUMBER() OVER(PARTITION BY CT.LastEditedBy ORDER BY TransactionDate DESC) AS rn
	FROM Sales.CustomerTransactions AS CT
	JOIN Application.People AS P
	ON P.PersonID = CT.LastEditedBy
	JOIN Sales.Customers AS C
	ON C.CustomerID = CT.CustomerID) AS LastTransaction
WHERE LastTransaction.rn = 1
ORDER BY PersonID;

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT * FROM
	(SELECT 
		CT.CustomerID,
		IL.StockItemID,
		StockItemName,
		IL.UnitPrice,
		CT.TransactionDate,
		ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY IL.UnitPrice DESC) AS rn
	FROM Warehouse.StockItems AS SI
	JOIN Sales.InvoiceLines AS IL
	ON IL.StockItemID = SI.StockItemID
	JOIN Sales.CustomerTransactions AS CT
	ON CT.InvoiceID = IL.InvoiceID) AS topItems
WHERE topItems.rn < 3 
ORDER BY CustomerID;

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 
