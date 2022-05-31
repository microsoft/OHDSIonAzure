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
    [condition_status_concept_id]   INT           NULL,
    CONSTRAINT [xpk_condition_occurrence] PRIMARY KEY NONCLUSTERED ([condition_occurrence_id] ASC),
    CONSTRAINT [fpk_condition_concept] FOREIGN KEY ([condition_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_condition_concept_s] FOREIGN KEY ([condition_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_condition_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_condition_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_condition_status_concept] FOREIGN KEY ([condition_status_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_condition_type_concept] FOREIGN KEY ([condition_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_condition_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_condition_visit_id]
    ON [dbo].[condition_occurrence]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_condition_concept_id]
    ON [dbo].[condition_occurrence]([condition_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_condition_person_id]
    ON [dbo].[condition_occurrence]([person_id] ASC);
