CREATE TABLE [dbo].[condition_occurrence] (
    [condition_occurrence_id]       INT           NOT NULL,
    [person_id]                     INT           NOT NULL,
    [condition_concept_id]          INT           NOT NULL,
    [condition_start_date]          DATE          NOT NULL,
    [condition_start_datetime]      DATETIME2 (7) NULL,
    [condition_end_date]            DATE          NULL,
    [condition_end_datetime]        DATETIME2 (7) NULL,
    [condition_type_concept_id]     INT           NOT NULL,
    [stop_reason]                   VARCHAR (20)  NULL,
    [provider_id]                   INT           NULL,
    [visit_occurrence_id]           INT           NULL,
    [visit_detail_id]               INT           NULL,
    [condition_source_value]        VARCHAR (50)  NULL,
    [condition_source_concept_id]   INT           NULL,
    [condition_status_source_value] VARCHAR (50)  NULL,
    [condition_status_concept_id]   INT           NULL
);
