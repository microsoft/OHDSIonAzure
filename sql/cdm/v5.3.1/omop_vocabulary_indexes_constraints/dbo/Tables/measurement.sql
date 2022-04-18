CREATE TABLE [dbo].[measurement] (
    [measurement_id]                INT           NOT NULL,
    [person_id]                     INT           NOT NULL,
    [measurement_concept_id]        INT           NOT NULL,
    [measurement_date]              DATE          NOT NULL,
    [measurement_datetime]          DATETIME2 (7) NULL,
    [measurement_time]              VARCHAR (10)  NULL,
    [measurement_type_concept_id]   INT           NOT NULL,
    [operator_concept_id]           INT           NULL,
    [value_as_number]               FLOAT (53)    NULL,
    [value_as_concept_id]           INT           NULL,
    [unit_concept_id]               INT           NULL,
    [range_low]                     FLOAT (53)    NULL,
    [range_high]                    FLOAT (53)    NULL,
    [provider_id]                   INT           NULL,
    [visit_occurrence_id]           INT           NULL,
    [visit_detail_id]               INT           NULL,
    [measurement_source_value]      VARCHAR (50)  NULL,
    [measurement_source_concept_id] INT           NULL,
    [unit_source_value]             VARCHAR (50)  NULL,
    [value_source_value]            VARCHAR (50)  NULL,
    CONSTRAINT [xpk_measurement] PRIMARY KEY NONCLUSTERED ([measurement_id] ASC),
    CONSTRAINT [fpk_measurement_concept] FOREIGN KEY ([measurement_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_measurement_concept_s] FOREIGN KEY ([measurement_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_measurement_operator] FOREIGN KEY ([operator_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_measurement_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_measurement_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_measurement_type_concept] FOREIGN KEY ([measurement_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_measurement_unit] FOREIGN KEY ([unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_measurement_value] FOREIGN KEY ([value_as_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_measurement_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_measurement_visit_id]
    ON [dbo].[measurement]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_measurement_concept_id]
    ON [dbo].[measurement]([measurement_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_measurement_person_id]
    ON [dbo].[measurement]([person_id] ASC);

