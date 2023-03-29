CREATE TABLE [dbo].[note] (
    [note_id]               INT           NOT NULL,
    [person_id]             INT           NOT NULL,
    [note_date]             DATE          NOT NULL,
    [note_datetime]         DATETIME2 (7) NULL,
    [note_type_concept_id]  INT           NOT NULL,
    [note_class_concept_id] INT           NOT NULL,
    [note_title]            VARCHAR (250) NULL,
    [note_text]             VARCHAR (MAX) NULL,
    [encoding_concept_id]   INT           NOT NULL,
    [language_concept_id]   INT           NOT NULL,
    [provider_id]           INT           NULL,
    [visit_occurrence_id]   INT           NULL,
    [visit_detail_id]       INT           NULL,
    [note_source_value]     VARCHAR (50)  NULL,
    CONSTRAINT [xpk_note] PRIMARY KEY NONCLUSTERED ([note_id] ASC),
    CONSTRAINT [fpk_language_concept] FOREIGN KEY ([language_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_note_class_concept] FOREIGN KEY ([note_class_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_note_encoding_concept] FOREIGN KEY ([encoding_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_note_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_note_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_note_type_concept] FOREIGN KEY ([note_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_note_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_note_visit_id]
    ON [dbo].[note]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_note_concept_id]
    ON [dbo].[note]([note_type_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_note_person_id]
    ON [dbo].[note]([person_id] ASC);
