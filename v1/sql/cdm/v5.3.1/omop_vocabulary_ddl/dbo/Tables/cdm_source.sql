CREATE TABLE [dbo].[cdm_source] (
    [cdm_source_name]                VARCHAR (255) NOT NULL,
    [cdm_source_abbreviation]        VARCHAR (25)  NULL,
    [cdm_holder]                     VARCHAR (255) NULL,
    [source_description]             VARCHAR (MAX) NULL,
    [source_documentation_reference] VARCHAR (255) NULL,
    [cdm_etl_reference]              VARCHAR (255) NULL,
    [source_release_date]            DATE          NULL,
    [cdm_release_date]               DATE          NULL,
    [cdm_version]                    VARCHAR (10)  NULL,
    [vocabulary_version]             VARCHAR (20)  NULL
);
