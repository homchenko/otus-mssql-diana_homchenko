CREATE DATABASE HospitalDB
USE HospitalDB
-- ************************************** [Department]
CREATE TABLE [Department]
(
 [IdDep]                   int NOT NULL ,
 [DepartmentName]          varchar(50) NOT NULL ,
 [NumOfBeds]               int NOT NULL ,
 [NumOfDoctors]            int NOT NULL ,
 [TotalDepartmentExpenses] int NOT NULL ,


 CONSTRAINT [PK_1] PRIMARY KEY CLUSTERED ([IdDep] ASC, [DepartmentName] ASC)
);
GO
-- ************************************** [Doctor]
CREATE TABLE [Doctor] 
(
 [IdDoc]          int NOT NULL ,
 [DoctorName]     varbinary(50) NOT NULL ,
 [IdDep]          int NOT NULL ,
 [DepartmentName] varchar(50) NOT NULL ,
 [Speciality]     varchar(50) NOT NULL ,


 CONSTRAINT [PK_Doc] PRIMARY KEY CLUSTERED ([IdDoc] ASC, [DoctorName] ASC),
 CONSTRAINT [FK_Doc] FOREIGN KEY ([IdDep], [DepartmentName])  REFERENCES [Department]([IdDep], [DepartmentName])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Doctor] 
 (
  [IdDep] ASC, 
  [DepartmentName] ASC
 )

GO
-- ************************************** [Diagnos_ICD_Full]
CREATE TABLE [Diagnos_ICD_Full]
(
 [Id_ICD]      varchar(50) NOT NULL ,
 [Description] varchar(100) NOT NULL ,


 CONSTRAINT [PK_Diag] PRIMARY KEY CLUSTERED ([Id_ICD] ASC)
);
GO
-- ************************************** [Analysis]
CREATE TABLE [Analysis]
(
 [IdTest]         int NOT NULL ,
 [Analis_Name]    varchar(50) NOT NULL ,
 [Analisis_Price] decimal(18,0) NOT NULL ,


 CONSTRAINT [PK_An] PRIMARY KEY CLUSTERED ([IdTest] ASC)
);
GO
-- ************************************** [Drugs]
CREATE TABLE [Drugs]
(
 [IdD]         int NOT NULL ,
 [Drug_Name]   varchar(50) NOT NULL ,
 [Indications] varchar(100) NOT NULL ,


 CONSTRAINT [PK_Dr] PRIMARY KEY CLUSTERED ([IdD] ASC)
);
GO
-- ************************************** [Patient]
CREATE TABLE [Patient]
(
 [IdP]             int NOT NULL ,
 [PatientFullName] varchar(50) NOT NULL ,
 [Date of Birth]   date NOT NULL ,
 [Adress]          varchar(100) NOT NULL ,
 [IdDep]           int NOT NULL ,
 [DepartmentName]  varchar(50) NOT NULL ,
 [IdDoc]           int NOT NULL ,
 [DoctorName]      varbinary(50) NOT NULL ,
 [Id_ICD]          varchar(50) NOT NULL ,
 [IdTest]          int NOT NULL ,
 [IdD]             int NOT NULL ,


 CONSTRAINT [PK_1P] PRIMARY KEY CLUSTERED ([IdP] ASC),
 CONSTRAINT [FK_2P] FOREIGN KEY ([IdDep], [DepartmentName])  REFERENCES [Department]([IdDep], [DepartmentName]),
 CONSTRAINT [FK_3P] FOREIGN KEY ([IdDoc], [DoctorName])  REFERENCES [Doctor]([IdDoc], [DoctorName]),
 CONSTRAINT [FK_4P] FOREIGN KEY ([Id_ICD])  REFERENCES [Diagnos_ICD_Full]([Id_ICD]),
 CONSTRAINT [FK_6P] FOREIGN KEY ([IdTest])  REFERENCES [Analysis]([IdTest]),
 CONSTRAINT [FK_8P] FOREIGN KEY ([IdD])  REFERENCES [Drugs]([IdD])
);
GO


CREATE NONCLUSTERED INDEX [FK_2] ON [Patient] 
 (
  [IdDep] ASC, 
  [DepartmentName] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_3] ON [Patient] 
 (
  [IdDoc] ASC, 
  [DoctorName] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_4] ON [Patient] 
 (
  [Id_ICD] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_5] ON [Patient] 
 (
  [IdTest] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_6] ON [Patient] 
 (
  [IdD] ASC
 )

GO
-- ************************************** [Therapy]
CREATE TABLE [Therapy]
(
 [IdT]       int NOT NULL ,
 [IdP]       int NOT NULL ,
 [Drug_Name] varchar(50) NOT NULL ,
 [Cost]      decimal(18,0) NOT NULL ,
 [Quantity]  int NOT NULL ,


 CONSTRAINT [PK_Ther] PRIMARY KEY CLUSTERED ([IdT] ASC),
 CONSTRAINT [FK_Ther] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP])
);
GO


CREATE NONCLUSTERED INDEX [FK_2Ther] ON [Therapy] 
 (
  [IdP] ASC
 )

GO
-- ************************************** [Patient_Reserch]
CREATE TABLE [Patient_Reserch]
(
 [IdR]           int NOT NULL ,
 [IdP]           int NOT NULL ,
 [Analisis_Name] varchar(50) NOT NULL ,
 [Cost]          decimal(18,0) NOT NULL ,
 [Quantity]      int NOT NULL ,


 CONSTRAINT [PK_Res] PRIMARY KEY CLUSTERED ([IdR] ASC),
 CONSTRAINT [FK_Res] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP])
);
GO


CREATE NONCLUSTERED INDEX [FK_2Res] ON [Patient_Reserch] 
 (
  [IdP] ASC
 )

GO
-- ************************************** [Patient_Expenses]
CREATE TABLE [Patient_Expenses]
(
 [IdEx]          int NOT NULL ,
 [IdP]           int NOT NULL ,
 [Room_Ex]       decimal(18,0) NOT NULL ,
 [Analisis_Ex]   decimal(18,0) NOT NULL ,
 [Therapy_Ex]    decimal(18,0) NOT NULL ,
 [Additional_Ex] decimal(18,0) NOT NULL ,
 [Total_Ex]      decimal(18,0) NOT NULL ,


 CONSTRAINT [PK_Ex] PRIMARY KEY CLUSTERED ([IdEx] ASC),
 CONSTRAINT [FK_Ex] FOREIGN KEY ([IdP])  REFERENCES [Patient]([IdP])
);
GO


CREATE NONCLUSTERED INDEX [FK_Ex] ON [Patient_Expenses] 
 (
  [IdP] ASC
 )

GO