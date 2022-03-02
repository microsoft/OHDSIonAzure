CREATE TABLE [dbo].[specimen] (
    [specimen_id]                 INT           NOT NULL,
    [person_id]                   INT           NOT NULL,
    [specimen_concept_id]         INT           NOT NULL,
    [specimen_type_concept_id]    INT           NOT NULL,
    [specimen_date]               DATE          NOT NULL,
    [specimen_datetime]           DATETIME2 (7) NULL,
    [quantity]                    FLOAT (53)    NULL,
    [unit_concept_id]             INT           NULL,
    [anatomic_site_concept_id]    INT           NULL,
    [disease_status_concept_id]   INT           NULL,
    [specimen_source_id]          VARCHAR (50)  NULL,
    [specimen_source_value]       VARCHAR (50)  NULL,
    [unit_source_value]           VARCHAR (50)  NULL,
    [anatomic_site_source_value]  VARCHAR (50)  NULL,
    [disease_status_source_value] VARCHAR (50)  NULL
);

