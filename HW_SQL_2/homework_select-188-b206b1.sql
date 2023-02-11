/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName 
FROM WideWorldImporters.Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%';

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT WideWorldImporters.Purchasing.Suppliers.SupplierID, SupplierName
FROM WideWorldImporters.Purchasing.Suppliers
LEFT JOIN WideWorldImporters.Purchasing.PurchaseOrders
ON  WideWorldImporters.Purchasing.Suppliers.SupplierID = WideWorldImporters.Purchasing.PurchaseOrders.SupplierID
WHERE WideWorldImporters.Purchasing.PurchaseOrders.PurchaseOrderID IS NULL;

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT WideWorldImporters.Sales.Orders.OrderID, 
FORMAT(OrderDate, 'd', 'de-de') AS [OrderDate], 
DATENAME(mm, OrderDate) AS [Month], 
DATENAME(qq, OrderDate) AS  [Quarter],
CustomerName
FROM WideWorldImporters.Sales.Customers
JOIN WideWorldImporters.Sales.Orders
ON WideWorldImporters.Sales.Customers.CustomerID = WideWorldImporters.Sales.Orders.CustomerID
JOIN WideWorldImporters.Sales.OrderLines
ON WideWorldImporters.Sales.Orders.OrderID = WideWorldImporters.Sales.OrderLines.OrderID
WHERE ((UnitPrice > 100) OR (Quantity > 20)) AND WideWorldImporters.Sales.OrderLines.PickingCompletedWhen IS NOT NULL
ORDER BY [Quarter], OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT DeliveryMethodName, ExpectedDeliveryDate, SupplierName, FullName AS ContactPerson, IsOrderFinalized
FROM WideWorldImporters.Purchasing.Suppliers
JOIN WideWorldImporters.Purchasing.PurchaseOrders ON WideWorldImporters.Purchasing.Suppliers.SupplierID = WideWorldImporters.Purchasing.PurchaseOrders.SupplierID
JOIN WideWorldImporters.Application.DeliveryMethods ON WideWorldImporters.Purchasing.PurchaseOrders.DeliveryMethodID = WideWorldImporters.Application.DeliveryMethods.DeliveryMethodID
JOIN WideWorldImporters.Application.People ON WideWorldImporters.Purchasing.PurchaseOrders.ContactPersonID = WideWorldImporters.Application.People.PersonID
WHERE YEAR(WideWorldImporters.Purchasing.PurchaseOrders.ExpectedDeliveryDate) = 2013
AND (WideWorldImporters.Application.DeliveryMethods.DeliveryMethodName = 'Air Freight' OR
WideWorldImporters.Application.DeliveryMethods.DeliveryMethodName = 'Refrigerated Air Freight')
AND WideWorldImporters.Purchasing.PurchaseOrders.IsOrderFinalized = 'true';

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10 CustomerName, FullName, OrderDate
FROM WideWorldImporters.Sales.Orders
JOIN WideWorldImporters.Sales.Customers ON WideWorldImporters.Sales.Orders.CustomerID = WideWorldImporters.Sales.Customers.CustomerID
JOIN WideWorldImporters.Application.People ON WideWorldImporters.Sales.Orders.ContactPersonID = WideWorldImporters.Application.People.PersonID
ORDER BY OrderDate DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT WideWorldImporters.Sales.Customers.CustomerID, CustomerName, PhoneNumber, StockItemName
FROM WideWorldImporters.Sales.Customers
JOIN WideWorldImporters.Sales.Orders ON WideWorldImporters.Sales.Customers.CustomerID = WideWorldImporters.Sales.Orders.CustomerID
JOIN WideWorldImporters.Sales.OrderLines ON WideWorldImporters.Sales.Orders.OrderID = WideWorldImporters.Sales.OrderLines.OrderID
JOIN WideWorldImporters.Warehouse.StockItems ON WideWorldImporters.Sales.OrderLines.StockItemID = WideWorldImporters.Warehouse.StockItems.StockItemID
WHERE StockItemName LIKE '%Chocolate frogs 250g%';
