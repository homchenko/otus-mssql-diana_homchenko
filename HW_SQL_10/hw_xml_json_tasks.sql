/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DECLARE @xmlDocument XML;

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\Program Files\Microsoft SQL Server\MSSQL16.SQLSERVER\MSSQL\Projects_SQL\HW_SQL_10\StockItems.xml', 
	SINGLE_CLOB)
AS data;

SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

SELECT @docHandle AS docHandle;

DROP TABLE IF EXISTS #Items_tmp;

CREATE TABLE #Items_tmp(
	[StockItemName] NVARCHAR(100),
	[SupplierID] INT,
	[UnitPackageID] INT,
	[OuterPackageID] INT,
	[QuantityPerOuter] INT,
	[TypicalWeightPerUnit] DECIMAL(18, 3),
	[LeadTimeDays] INT,
	[IsChillerStock] BIT, 
	[TaxRate] DECIMAL(18, 3), 
	[UnitPrice] DECIMAL (18, 2)
);

INSERT INTO #Items_tmp
SELECT * FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] NVARCHAR(100) '@Name',
	[SupplierID] INT 'SupplierID',
	[UnitPackageID] INT 'Package/UnitPackageID',
	[OuterPackageID] INT 'Package/OuterPackageID',
	[QuantityPerOuter] INT 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] DECIMAL(18, 3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] INT 'LeadTimeDays',
	[IsChillerStock] BIT 'IsChillerStock', 
	[TaxRate] DECIMAL(18, 3) 'TaxRate', 
	[UnitPrice] DECIMAL (18, 2) 'UnitPrice'
);

SELECT * FROM #Items_tmp;

MERGE Warehouse.StockItems AS target
USING #Items_tmp
ON target.StockItemName COLLATE Latin1_General_CS_AS = #Items_tmp.StockItemName COLLATE Latin1_General_CS_AS
WHEN MATCHED
	THEN UPDATE SET
	target.SupplierID = #Items_tmp.SupplierID
	, target.UnitPackageID = #Items_tmp.UnitPackageID
	, target.OuterPackageID = #Items_tmp.OuterPackageID
	, target.QuantityPerOuter = #Items_tmp.QuantityPerOuter
	, target.TypicalWeightPerUnit = #Items_tmp.TypicalWeightPerUnit
	, target.LeadTimeDays = #Items_tmp.LeadTimeDays
	, target.IsChillerStock = #Items_tmp.IsChillerStock
	, target.TaxRate = #Items_tmp.TaxRate
	, target.UnitPrice = #Items_tmp.UnitPrice
	WHEN NOT MATCHED
	THEN INSERT(
	StockItemName
	, SupplierID
	, UnitPackageID
	, OuterPackageID
	, QuantityPerOuter
	, TypicalWeightPerUnit
	, LeadTimeDays
	, IsChillerStock
	, TaxRate
	, UnitPrice
	, LastEditedBy
	, ValidFrom
	, ValidTo
	) VALUES(
	#Items_tmp.StockItemName
	, #Items_tmp.SupplierID
	, #Items_tmp.UnitPackageID
	, #Items_tmp.OuterPackageID
	, #Items_tmp.QuantityPerOuter
	, #Items_tmp.TypicalWeightPerUnit
	, #Items_tmp.LeadTimeDays
	, #Items_tmp.IsChillerStock
	, #Items_tmp.TaxRate
	, #Items_tmp.UnitPrice
	, 1
	, DEFAULT
	, DEFAULT
);

SELECT TOP 20 *
FROM Warehouse.StockItems AS S
ORDER BY S.StockItemID DESC;

EXEC sp_xml_removedocument @docHandle;

DROP TABLE IF EXISTS #Items_tmp;

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DECLARE @xmlDocumentNew XML;
SET @xmlDocumentNew = (
SELECT *
FROM OPENROWSET(BULK 'D:\Program Files\Microsoft SQL Server\MSSQL16.SQLSERVER\MSSQL\Projects_SQL\HW_SQL_10\StockItems.xml', SINGLE_CLOB) AS XMLDocN);

WITH Items_tmp AS(
SELECT
	I.Item.value('(@Name)[1]', 'NVARCHAR(100)') AS [StockItemName],
	I.Item.value('(SupplierID)[1]', 'INT') AS [SupplierID],
	I.Item.value('(Package/UnitPackageID)[1]', 'INT') AS [UnitPackageID],
	I.Item.value('(Package/OuterPackageID)[1]', 'INT') AS [OuterPackageID],
	I.Item.value('(Package/QuantityPerOuter)[1]', 'INT') AS [QuantityPerOuter],
	I.Item.value('(Package/TypicalWeightPerUnit)[1]', 'DECIMAL(18, 3)') AS [TypicalWeightPerUnit],
	I.Item.value('(LeadTimeDays)[1]', 'INT') AS [LeadTimeDays],
	I.Item.value('(IsChillerStock)[1]', 'BIT') AS [IsChillerStock],
	I.Item.value('(TaxRate)[1]', 'DECIMAL(18, 3)') AS [TaxRate],
	I.Item.value('(UnitPrice)[1]', 'DECIMAL (18, 2)') AS [UnitPrice]/*,
	I.Item.query('.')*/
FROM @xmlDocumentNew.nodes('/StockItems/Item') AS I(Item)) --таблица I с одним столбцом Item, содержащая данные типа XML

MERGE Warehouse.StockItems AS target
USING Items_tmp
ON target.StockItemName COLLATE Latin1_General_CS_AS = Items_tmp.StockItemName COLLATE Latin1_General_CS_AS
WHEN MATCHED
	THEN UPDATE SET
	target.SupplierID = Items_tmp.SupplierID
	, target.UnitPackageID = Items_tmp.UnitPackageID
	, target.OuterPackageID = Items_tmp.OuterPackageID
	, target.QuantityPerOuter = Items_tmp.QuantityPerOuter
	, target.TypicalWeightPerUnit = Items_tmp.TypicalWeightPerUnit
	, target.LeadTimeDays = Items_tmp.LeadTimeDays
	, target.IsChillerStock = Items_tmp.IsChillerStock
	, target.TaxRate = Items_tmp.TaxRate
	, target.UnitPrice = Items_tmp.UnitPrice
	WHEN NOT MATCHED
	THEN INSERT(
	StockItemName
	, SupplierID
	, UnitPackageID
	, OuterPackageID
	, QuantityPerOuter
	, TypicalWeightPerUnit
	, LeadTimeDays
	, IsChillerStock
	, TaxRate
	, UnitPrice
	, LastEditedBy
	, ValidFrom
	, ValidTo
	) VALUES(
	Items_tmp.StockItemName
	, Items_tmp.SupplierID
	, Items_tmp.UnitPackageID
	, Items_tmp.OuterPackageID
	, Items_tmp.QuantityPerOuter
	, Items_tmp.TypicalWeightPerUnit
	, Items_tmp.LeadTimeDays
	, Items_tmp.IsChillerStock
	, Items_tmp.TaxRate
	, Items_tmp.UnitPrice
	, 1
	, DEFAULT
	, DEFAULT
);

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT TOP 10
	StockItemName AS[@Name]
	, SupplierID AS [SupplierID]
	, UnitPackageID AS [Package/UnitPackageID]
	, OuterPackageID AS [Package/OuterPackageID]
	, QuantityPerOuter AS [Package/QuantityPerOuter]
	, TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit]
	, LeadTimeDays AS [LeadTimeDays]
	, IsChillerStock AS [IsChillerStock]
	, TaxRate AS TaxRate
	, UnitPrice AS [UnitPrice]
	, 'Tags' + Tags AS "comment()"
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems');

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT
	StockItemID,
	StockItemName,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[1]') AS FirstTag
FROM Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT
	StockItemID,
	StockItemName,
	JSON_QUERY(CustomFields, '$.Tags') AS TAGS
	/*(SELECT s.CustomFields + ',' AS 'data()'
	FROM Warehouse.StockItems AS s
	FOR XML PATH('')) AS Tags*/
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') AS tagsJSON
WHERE tagsJSON.value = 'Vintage'
