CREATE TABLE [dbo].[drug_exposure] (
    [drug_exposure_id]             INT           NOT NULL,
    [person_id]                    INT           NOT NULL,
    [drug_concept_id]              INT           NOT NULL,
    [drug_exposure_start_date]     DATE          NOT NULL,
    [drug_exposure_start_datetime] DATETIME2 (7) NULL,
    [drug_exposure_end_date]       DATE          NOT NULL,
    [drug_exposure_end_datetime]   DATETIME2 (7) NULL,
    [verbatim_end_date]            DATE          NULL,
    [drug_type_concept_id]         INT           NOT NULL,
    [stop_reason]                  VARCHAR (20)  NULL,
    [refills]                      INT           NULL,
    [quantity]                     FLOAT (53)    NULL,
    [days_supply]                  INT           NULL,
    [sig]                          VARCHAR (MAX) NULL,
    [route_concept_id]             INT           NULL,
    [lot_number]                   VARCHAR (50)  NULL,
    [provider_id]                  INT           NULL,
    [visit_occurrence_id]          INT           NULL,
    [visit_detail_id]              INT           NULL,
    [drug_source_value]            VARCHAR (50)  NULL,
    [drug_source_concept_id]       INT           NULL,
    [route_source_value]           VARCHAR (50)  NULL,
    [dose_unit_source_value]       VARCHAR (50)  NULL
);
