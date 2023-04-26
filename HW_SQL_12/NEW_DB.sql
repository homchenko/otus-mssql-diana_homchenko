CREATE DATABASE Hospital_DB
USE Hospital_DB

-- ************************************** [Department]
CREATE TABLE [Department]
(
 [IdDep]                     int NOT NULL ,
 [Department_Name]           nvarchar(100) NOT NULL ,
 [Num_Of_Beds]               int NOT NULL ,
 [Num_Of_Doctors]            int NOT NULL ,
 [Total_Department_Expenses] decimal(18,2) NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdDep] ASC)
);
GO
-- ************************************** [Doctor]
CREATE TABLE [Doctor]
(
 [IdDoc]       int NOT NULL ,
 [Doctor_Name] nvarchar(100) NOT NULL ,
 [Speciality]  nvarchar(100) NOT NULL ,
 [Address]     nvarchar(200) NOT NULL ,
 [Phone]       nvarchar(50) NULL ,
 [IdDep]       int NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdDoc] ASC),
 CONSTRAINT [FK_1] FOREIGN KEY ([IdDep])  REFERENCES [Department]([IdDep])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Doctor] 
 (
  [IdDep] ASC
 )

GO
-- ************************************** [Patient]
CREATE TABLE [Patient]
(
 [IdP]           int NOT NULL ,
 [Full_Name]     nvarchar(100) NOT NULL ,
 [Date_Of_Birth] date NOT NULL ,
 [Address]       nvarchar(200) NOT NULL ,
 [Phone]         nvarchar(50) NULL ,
 [IdDep]         int NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdP] ASC),
 CONSTRAINT [FK_4] FOREIGN KEY ([IdDep])  REFERENCES [Department]([IdDep])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Patient] 
 (
  [IdDep] ASC
 )

GO
-- ************************************** [Patient_Doctor]
CREATE TABLE [Patient_Doctor]
(
 [IdP_D]      int NOT NULL ,
 [IdP]        int NOT NULL ,
 [IdDoc]      int NOT NULL ,
 [Attending]  binary(50) NULL ,
 [Consultant] binary(50) NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdP_D] ASC),
 CONSTRAINT [FK_2] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP]),
 CONSTRAINT [FK_3] FOREIGN KEY ([IdDoc])  REFERENCES [Doctor]([IdDoc])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Patient_Doctor] 
 (
  [IdP] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_3] ON [Patient_Doctor] 
 (
  [IdDoc] ASC
 )

GO
-- ************************************** [Diagnos_ICO_Catalog]
CREATE TABLE [Diagnos_ICO_Catalog]
(
 [IdD_ICO]     nvarchar(50) NOT NULL ,
 [Description] nvarchar(100) NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdD_ICO] ASC)
);
GO
-- ************************************** [Patient_Diagnos]
CREATE TABLE [Patient_Diagnos]
(
 [IdP_ICO] int NOT NULL ,
 [IdP]     int NOT NULL ,
 [IdD_ICO] nvarchar(50) NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdP_ICO] ASC),
 CONSTRAINT [FK_5] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP]),
 CONSTRAINT [FK_6] FOREIGN KEY ([IdD_ICO])  REFERENCES [Diagnos_ICO_Catalog]([IdD_ICO])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Patient_Diagnos] 
 (
  [IdP] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_3] ON [Patient_Diagnos] 
 (
  [IdD_ICO] ASC
 )

GO
-- ************************************** [Analis_Catalog]
CREATE TABLE [Analis_Catalog]
(
 [Id_Test]     int NOT NULL ,
 [Analis_Name] nvarchar(50) NOT NULL ,
 [Description] nvarchar(200) NOT NULL ,
 [Price]       decimal(18,2) NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([Id_Test] ASC)
);
GO
-- ************************************** [Patient_Research]
CREATE TABLE [Patient_Research]
(
 [IdR]      int NOT NULL ,
 [IdP]      int NOT NULL ,
 [Id_Test]  int NOT NULL ,
 [Cost]     decimal(18,2) NOT NULL ,
 [Quantity] int NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdR] ASC),
 CONSTRAINT [FK_7] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP]),
 CONSTRAINT [FK_8] FOREIGN KEY ([Id_Test])  REFERENCES [Analis_Catalog]([Id_Test])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Patient_Research] 
 (
  [IdP] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_3] ON [Patient_Research] 
 (
  [Id_Test] ASC
 )

GO
-- ************************************** [Drug_Catalog]
CREATE TABLE [Drug_Catalog]
(
 [IdDr]        int NOT NULL ,
 [Drug_Name]   nvarchar(100) NOT NULL ,
 [Description] nvarchar(300) NOT NULL ,
 [Price]       decimal(18,2) NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdDr] ASC)
);
GO
-- ************************************** [Therapy]
CREATE TABLE [Therapy]
(
 [IdT]      int NOT NULL ,
 [IdP]      int NOT NULL ,
 [IdDr]     int NOT NULL ,
 [Quantity] float NOT NULL ,
 [Cost]     decimal(18,2) NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdT] ASC),
 CONSTRAINT [FK_10] FOREIGN KEY ([IdDr])  REFERENCES [Drug_Catalog]([IdDr]),
 CONSTRAINT [FK_9] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Therapy] 
 (
  [IdP] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_3] ON [Therapy] 
 (
  [IdDr] ASC
 )

GO
-- ************************************** [Patient_Expenses]
CREATE TABLE [Patient_Expenses]
(
 [IdEx]          int NOT NULL ,
 [IdP]           int NOT NULL ,
 [Room_Ex]       decimal(18,2) NULL ,
 [Analisis_Ex]   decimal(18,2) NULL ,
 [Therapy_Ex]    decimal(18,2) NULL ,
 [Additional_Ex] decimal(18,2) NULL ,
 [Total_Ex]      decimal(18,2) NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdEx] ASC),
 CONSTRAINT [FK_11] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Patient_Expenses] 
 (
  [IdP] ASC
 )

GO
