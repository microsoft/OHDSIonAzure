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

-- remove any previously added database connection configuration data
DELETE webapi.source_daimon;
DELETE webapi.source;

-- TODO: Should this exist in the webapi instead? For now, allowing null based on insert
ALTER TABLE [webapi].[source]
ALTER COLUMN [krb_auth_method] [varchar](10) NULL -- NOT NULL in existing setup, setting to NULL based on insert

-- SET webapi CDM source
INSERT INTO webapi.source( source_id, source_name, source_key, source_connection, source_dialect)
VALUES (1, 'webapi CDM V5 Database', 'webapi-CDMV5','$(SOURCE_CONNECTION)', 'sql server');

-- CDM daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (1, 1, 0, 'dbo', 2);

-- VOCABULARY daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (2, 1, 1, 'dbo', 2);

-- RESULTS daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (3, 1, 2, 'webapi', 2);

-- EVIDENCE daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 1, 3, 'webapi', 2);