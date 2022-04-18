CREATE TABLE [dbo].[device_exposure] (
    [device_exposure_id]             INT           NOT NULL,
    [person_id]                      INT           NOT NULL,
    [device_concept_id]              INT           NOT NULL,
    [device_exposure_start_date]     DATE          NOT NULL,
    [device_exposure_start_datetime] DATETIME2 (7) NULL,
    [device_exposure_end_date]       DATE          NULL,
    [device_exposure_end_datetime]   DATETIME2 (7) NULL,
    [device_type_concept_id]         INT           NOT NULL,
    [unique_device_id]               VARCHAR (500) NULL, -- OMOP Expansion for synthea data
    [quantity]                       INT           NULL,
    [provider_id]                    INT           NULL,
    [visit_occurrence_id]            INT           NULL,
    [visit_detail_id]                INT           NULL,
    [device_source_value]            VARCHAR (100) NULL,
    [device_source_concept_id]       INT           NULL
);

