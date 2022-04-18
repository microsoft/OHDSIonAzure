CREATE TABLE [dbo].[procedure_occurrence] (
    [procedure_occurrence_id]     INT           NOT NULL,
    [person_id]                   INT           NOT NULL,
    [procedure_concept_id]        INT           NOT NULL,
    [procedure_date]              DATE          NOT NULL,
    [procedure_datetime]          DATETIME2 (7) NULL,
    [procedure_type_concept_id]   INT           NOT NULL,
    [modifier_concept_id]         INT           NULL,
    [quantity]                    INT           NULL,
    [provider_id]                 INT           NULL,
    [visit_occurrence_id]         INT           NULL,
    [visit_detail_id]             INT           NULL,
    [procedure_source_value]      VARCHAR (50)  NULL,
    [procedure_source_concept_id] INT           NULL,
    [modifier_source_value]       VARCHAR (50)  NULL
);

