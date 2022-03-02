CREATE TABLE [dbo].[death] (
    [person_id]               INT           NOT NULL,
    [death_date]              DATE          NOT NULL,
    [death_datetime]          DATETIME2 (7) NULL,
    [death_type_concept_id]   INT           NOT NULL,
    [cause_concept_id]        INT           NULL,
    [cause_source_value]      VARCHAR (50)  NULL,
    [cause_source_concept_id] INT           NULL,
    CONSTRAINT [xpk_death] PRIMARY KEY NONCLUSTERED ([person_id] ASC),
    CONSTRAINT [fpk_death_cause_concept] FOREIGN KEY ([cause_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_death_cause_concept_s] FOREIGN KEY ([cause_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_death_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_death_type_concept] FOREIGN KEY ([death_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE CLUSTERED INDEX [idx_death_person_id]
    ON [dbo].[death]([person_id] ASC);

