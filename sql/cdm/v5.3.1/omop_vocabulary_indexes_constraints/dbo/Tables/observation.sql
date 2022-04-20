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
    [qualifier_source_value]        VARCHAR (50)  NULL,
    CONSTRAINT [xpk_observation] PRIMARY KEY NONCLUSTERED ([observation_id] ASC),
    CONSTRAINT [fpk_observation_concept] FOREIGN KEY ([observation_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_observation_concept_s] FOREIGN KEY ([observation_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_observation_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_observation_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_observation_qualifier] FOREIGN KEY ([qualifier_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_observation_type_concept] FOREIGN KEY ([observation_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_observation_unit] FOREIGN KEY ([unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_observation_value] FOREIGN KEY ([value_as_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_observation_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_observation_visit_id]
    ON [dbo].[observation]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_observation_concept_id]
    ON [dbo].[observation]([observation_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_observation_person_id]
    ON [dbo].[observation]([person_id] ASC);
