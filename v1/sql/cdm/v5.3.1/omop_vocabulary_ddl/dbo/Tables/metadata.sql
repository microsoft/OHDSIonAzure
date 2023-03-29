CREATE TABLE [dbo].[metadata] (
    [metadata_concept_id]      INT           NOT NULL,
    [metadata_type_concept_id] INT           NOT NULL,
    [name]                     VARCHAR (250) NOT NULL,
    [value_as_string]          VARCHAR (MAX) NULL,
    [value_as_concept_id]      INT           NULL,
    [metadata_date]            DATE          NULL,
    [metadata_datetime]        DATETIME2 (7) NULL
);
