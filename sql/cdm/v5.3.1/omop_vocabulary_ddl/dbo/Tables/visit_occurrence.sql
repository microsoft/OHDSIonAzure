CREATE TABLE [dbo].[visit_occurrence] (
    [visit_occurrence_id]           INT           NOT NULL,
    [person_id]                     INT           NOT NULL,
    [visit_concept_id]              INT           NOT NULL,
    [visit_start_date]              DATE          NOT NULL,
    [visit_start_datetime]          DATETIME2 (7) NULL,
    [visit_end_date]                DATE          NOT NULL,
    [visit_end_datetime]            DATETIME2 (7) NULL,
    [visit_type_concept_id]         INT           NOT NULL,
    [provider_id]                   INT           NULL,
    [care_site_id]                  INT           NULL,
    [visit_source_value]            VARCHAR (50)  NULL,
    [visit_source_concept_id]       INT           NULL,
    [admitting_source_concept_id]   INT           NULL,
    [admitting_source_value]        VARCHAR (50)  NULL,
    [discharge_to_concept_id]       INT           NULL,
    [discharge_to_source_value]     VARCHAR (50)  NULL,
    [preceding_visit_occurrence_id] INT           NULL
);
