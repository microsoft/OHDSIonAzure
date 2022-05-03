/*
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.
 Use SQLCMD syntax to include a file in the post-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/
-- Used for local testing

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'concept')
BEGIN
  PRINT('Concept table exists')
  TRUNCATE TABLE concept
END
ELSE
BEGIN
  PRINT('Concept table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'concept_ancestor')
BEGIN
  PRINT('concept_ancestor table exists')
  TRUNCATE TABLE concept_ancestor
END
ELSE
BEGIN
  PRINT('concept_ancestor table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'concept_class')
BEGIN
  PRINT('concept_class table exists')
  TRUNCATE TABLE concept_class
END
ELSE
BEGIN
  PRINT('concept_class table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'concept_relationship')
BEGIN
  PRINT('concept_relationship table exists')
  TRUNCATE TABLE concept_relationship
END
ELSE
BEGIN
  PRINT('concept_relationship table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'concept_synonym')
BEGIN
  PRINT('concept_synonym table exists')
  TRUNCATE TABLE concept_synonym
END
ELSE
BEGIN
  PRINT('concept_synonym table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'domain')
BEGIN
  PRINT('domain table exists')
  TRUNCATE TABLE domain
END
ELSE
BEGIN
  PRINT('domain table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'drug_strength')
BEGIN
  PRINT('drug_strength table exists')
  TRUNCATE TABLE drug_strength
END
ELSE
BEGIN
  PRINT('drug_strength table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'relationship')
BEGIN
  PRINT('relationship table exists')
  TRUNCATE TABLE relationship
END
ELSE
BEGIN
  PRINT('relationship table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'source_to_concept_map')
BEGIN
  PRINT('source_to_concept_map table exists')
  TRUNCATE TABLE source_to_concept_map
END
ELSE
BEGIN
  PRINT('source_to_concept_map table does not exist')
END
GO

IF EXISTS (SELECT table_name FROM INFORMATION_SCHEMA.TABLES
           WHERE table_name = N'vocabulary')
BEGIN
  PRINT('vocabulary table exists')
  TRUNCATE TABLE vocabulary
END
ELSE
BEGIN
  PRINT('vocabulary table does not exist')
END

GO -- noqa: PRS
BULK INSERT concept -- noqa: PRS
FROM '/CONCEPT.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT concept_ancestor
FROM '/CONCEPT_ANCESTOR.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT concept_class
FROM '/CONCEPT_CLASS.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT concept_relationship
FROM '/CONCEPT_RELATIONSHIP.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT concept_synonym
FROM '/CONCEPT_SYNONYM.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT domain
FROM '/DOMAIN.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT drug_strength
FROM '/DRUG_STRENGTH.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT relationship
FROM '/RELATIONSHIP.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT source_to_concept_map
FROM '/source_to_concept_map.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO

BULK INSERT vocabulary
-- Test data modification to remove duplicates
FROM '/VOCABULARY.csv'
WITH (DATA_SOURCE = '',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);
GO
