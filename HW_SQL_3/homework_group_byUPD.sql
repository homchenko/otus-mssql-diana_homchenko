/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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

USE WideWorldImporters;

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(i.InvoiceDate) AS [Year], 
	MONTH(i.InvoiceDate) AS [Month],
	s.StockItemName, 
	SUM(s.UnitPrice * il.Quantity) AS [SumPrice], 
	AVG(s.UnitPrice) AS [AvgSum]
FROM Sales.Invoices  i
JOIN Sales.InvoiceLines  il
ON i.InvoiceID = il.InvoiceID
JOIN Warehouse.StockItems s
ON il.StockItemID = s.StockItemID
/*WHERE YEAR(i.InvoiceDate) = 2015 
AND MONTH(i.InvoiceDate) = 4*/
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
Сортировка по году и месяцу.

*/

SELECT YEAR(i.InvoiceDate) AS [Year], 
	MONTH(i.InvoiceDate) AS [Month],
	s.StockItemName, 
	SUM(s.UnitPrice * il.Quantity) AS [SumPrice]
FROM Sales.Invoices  i
JOIN Sales.InvoiceLines  il
ON i.InvoiceID = il.InvoiceID
JOIN Warehouse.StockItems s
ON il.StockItemID = s.StockItemID
/*WHERE YEAR(i.InvoiceDate) = 2015 
AND MONTH(i.InvoiceDate) = 4*/
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName
HAVING SUM(s.UnitPrice * il.Quantity) > 4600000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName;

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(i.InvoiceDate) AS [Year], 
	MONTH(i.InvoiceDate) AS [Month],
	s.StockItemName, 
	SUM(s.UnitPrice) AS [SumPrice],
	SUM(il.Quantity) AS [Quantity sold]
FROM Sales.Invoices  i
JOIN Sales.InvoiceLines  il
ON i.InvoiceID = il.InvoiceID
JOIN Warehouse.StockItems s
ON il.StockItemID = s.StockItemID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName
HAVING SUM(il.Quantity) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), s.StockItemName;
-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
4. Написать второй запрос ("Отобразить все месяцы, где общая сумма продаж превысила 4 600 000") 
за период 2015 год так, чтобы месяц, в котором сумма продаж была меньше указанной суммы также отображался в результатах,
но в качестве суммы продаж было бы '-'.
Сортировка по году и месяцу.

Пример результата:
-----+-------+------------
Year | Month | SalesTotal
-----+-------+------------
2015 | 1     | -
2015 | 2     | -
2015 | 3     | -
2015 | 4     | 5073264.75
2015 | 5     | -
2015 | 6     | -
2015 | 7     | 5155672.00
2015 | 8     | -
2015 | 9     | 4662600.00
2015 | 10    | -
2015 | 11    | -
2015 | 12    | -

*/
