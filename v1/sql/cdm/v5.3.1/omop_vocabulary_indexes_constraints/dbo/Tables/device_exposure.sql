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
    [device_source_concept_id]       INT           NULL,
    CONSTRAINT [xpk_device_exposure] PRIMARY KEY NONCLUSTERED ([device_exposure_id] ASC),
    CONSTRAINT [fpk_device_concept] FOREIGN KEY ([device_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_device_concept_s] FOREIGN KEY ([device_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_device_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_device_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_device_type_concept] FOREIGN KEY ([device_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_device_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_device_visit_id]
    ON [dbo].[device_exposure]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_device_concept_id]
    ON [dbo].[device_exposure]([device_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_device_person_id]
    ON [dbo].[device_exposure]([person_id] ASC);
