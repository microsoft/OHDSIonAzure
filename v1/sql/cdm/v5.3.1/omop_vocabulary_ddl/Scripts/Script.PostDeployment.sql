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

-- TODO: wrap in transaction

IF NOT EXISTS(
  SELECT
    eds.[name],
    eds.[location],
    eds.[type_desc]
FROM sys.external_data_sources eds
WHERE eds.name = '$(DSVocabularyBlobStorageName)')
BEGIN
	RAISERROR ('Data source not found.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END
ELSE
BEGIN
	PRINT 'Able to find the Data Source!'
END


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


DECLARE @row_count int

-- concept
SELECT @row_count = COUNT(*) FROM concept

PRINT('Before Bulk Insert concept Table has ' + CONVERT(varchar(20), @row_count) + ' rows')  -- noqa: PRS


BULK INSERT concept -- noqa: PRS
FROM '$(VocabulariesContainerPath)/CONCEPT.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from concept

PRINT('After Bulk Insert concept Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

-- Reverse Test
-- IF @row_count !> 0
IF @row_count > 0
BEGIN
	PRINT('concept Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('concept Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END

-- concept_ancestor
SELECT @row_count = COUNT(*) from concept_ancestor

PRINT('Before Bulk Insert concept_ancestor Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT concept_ancestor
FROM '$(VocabulariesContainerPath)/CONCEPT_ANCESTOR.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);

SELECT @row_count = COUNT(*) from concept_ancestor

PRINT('After Bulk Insert concept_ancestor Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

-- Reverse Test
-- IF @row_count !> 0
IF @row_count > 0
BEGIN
	PRINT('concept_ancestor Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('concept_ancestor Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END

-- concept_class
SELECT @row_count = COUNT(*) from concept_class

PRINT('Before Bulk Insert concept_class Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT concept_class
FROM '$(VocabulariesContainerPath)/CONCEPT_CLASS.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);

SELECT @row_count = COUNT(*) from concept_class

PRINT('After Bulk Insert concept_class Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

IF @row_count > 0
BEGIN
	PRINT('concept_class Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('concept_class Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END

-- concept_relationship
SELECT @row_count = COUNT(*) from concept_relationship

PRINT('Before Bulk Insert concept_relationship Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT concept_relationship
FROM '$(VocabulariesContainerPath)/CONCEPT_RELATIONSHIP.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);

SELECT @row_count = COUNT(*) from concept_relationship

PRINT('After Bulk Insert concept_relationship Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

IF @row_count > 0
BEGIN
	PRINT('concept_relationship Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('concept_relationship Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END

-- concept_synonym
SELECT @row_count = COUNT(*) from concept_synonym

PRINT('Before Bulk Insert concept_synonym Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT concept_synonym
FROM '$(VocabulariesContainerPath)/CONCEPT_SYNONYM.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from concept_synonym

PRINT('After Bulk Insert concept_synonym Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


IF @row_count > 0
BEGIN
	PRINT('concept_synonym Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('concept_synonym Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END


-- domain
SELECT @row_count = COUNT(*) from domain

PRINT('Before Bulk Insert domain Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT domain
FROM '$(VocabulariesContainerPath)/DOMAIN.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from domain

PRINT('After Bulk Insert domain Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


IF @row_count > 0
BEGIN
	PRINT('domain Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('domain Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END


-- drug_strength
SELECT @row_count = COUNT(*) from drug_strength

PRINT('Before Bulk Insert drug_strength Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


BULK INSERT drug_strength
FROM '$(VocabulariesContainerPath)/DRUG_STRENGTH.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from drug_strength

PRINT('After Bulk Insert drug_strength Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


IF @row_count > 0
BEGIN
	PRINT('drug_strength Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('drug_strength Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END


-- relationship
SELECT @row_count = COUNT(*) from relationship

PRINT('Before Bulk Insert relationship Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


BULK INSERT relationship
FROM '$(VocabulariesContainerPath)/RELATIONSHIP.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from relationship

PRINT('After Bulk Insert relationship Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


IF @row_count > 0
BEGIN
	PRINT('relationship Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('relationship Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END


-- source_to_concept_map
-- note example source_to_concept_map needs to be included in the vocabulariesContainerPath
SELECT @row_count = COUNT(*) from source_to_concept_map

PRINT('Before Bulk Insert source_to_concept_map Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT source_to_concept_map
FROM '$(VocabulariesContainerPath)/source_to_concept_map.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from source_to_concept_map

PRINT('After Bulk Insert source_to_concept_map Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

IF @row_count > 0
BEGIN
  RAISERROR ('source_to_concept_map Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END
ELSE
BEGIN
  -- source_to_concept_map should be an empty table
	PRINT('source_to_concept_map Table has 0 rows')
END


-- vocabulary
SELECT @row_count = COUNT(*) from vocabulary

PRINT('Before Bulk Insert vocabulary Table has ' + CONVERT(varchar(20), @row_count) + ' rows')

BULK INSERT vocabulary
-- Test data modification to remove duplicates
FROM '$(VocabulariesContainerPath)/VOCABULARY.csv'
WITH (DATA_SOURCE = '$(DSVocabularyBlobStorageName)',
	FIRSTROW = 2,
	FIELDTERMINATOR = '\t',
	ROWTERMINATOR = '0x0a',
	TABLOCK);


SELECT @row_count = COUNT(*) from vocabulary

PRINT('After Bulk Insert vocabulary Table has ' + CONVERT(varchar(20), @row_count) + ' rows')


IF @row_count > 0
BEGIN
	PRINT('vocabulary Table has greater than 0 rows')
END
ELSE
BEGIN
	RAISERROR ('vocabulary Table has 0 rows.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
END
