CREATE TABLE [dbo].[observation] (
    [observation_id]                INT           NOT NULL,
    [person_id]                     INT           NOT NULL,
    [observation_concept_id]        INT           NOT NULL,
    [observation_date]              DATE          NOT NULL,
    [observation_datetime]          DATETIME2 (7) NULL,
    [observation_type_concept_id]   INT           NOT NULL,
    [value_as_number]               FLOAT (53)    NULL,
    [value_as_string]               VARCHAR (60)  NULL,
    [value_as_concept_id]           INT           NULL,
    [qualifier_concept_id]          INT           NULL,
    [unit_concept_id]               INT           NULL,
    [provider_id]                   INT           NULL,
    [visit_occurrence_id]           INT           NULL,
    [visit_detail_id]               INT           NULL,
    [observation_source_value]      VARCHAR (50)  NULL,
    [observation_source_concept_id] INT           NULL,
    [unit_source_value]             VARCHAR (50)  NULL,
    [qualifier_source_value]        VARCHAR (50)  NULL
);
