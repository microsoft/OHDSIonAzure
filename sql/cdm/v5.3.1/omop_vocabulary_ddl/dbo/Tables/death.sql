CREATE TABLE [dbo].[death] (
    [person_id]               INT           NOT NULL,
    [death_date]              DATE          NOT NULL,
    [death_datetime]          DATETIME2 (7) NULL,
    [death_type_concept_id]   INT           NOT NULL,
    [cause_concept_id]        INT           NULL,
    [cause_source_value]      VARCHAR (50)  NULL,
    [cause_source_concept_id] INT           NULL
);
