CREATE TABLE [dbo].[payer_plan_period] (
    [payer_plan_period_id]          INT          NOT NULL,
    [person_id]                     INT          NOT NULL,
    [payer_plan_period_start_date]  DATE         NOT NULL,
    [payer_plan_period_end_date]    DATE         NOT NULL,
    [payer_concept_id]              INT          NULL,
    [payer_source_value]            VARCHAR (50) NULL,
    [payer_source_concept_id]       INT          NULL,
    [plan_concept_id]               INT          NULL,
    [plan_source_value]             VARCHAR (50) NULL,
    [plan_source_concept_id]        INT          NULL,
    [sponsor_concept_id]            INT          NULL,
    [sponsor_source_value]          VARCHAR (50) NULL,
    [sponsor_source_concept_id]     INT          NULL,
    [family_source_value]           VARCHAR (50) NULL,
    [stop_reason_concept_id]        INT          NULL,
    [stop_reason_source_value]      VARCHAR (50) NULL,
    [stop_reason_source_concept_id] INT          NULL
);
