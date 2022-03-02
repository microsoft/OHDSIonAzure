CREATE TABLE [dbo].[note_nlp] (
    [note_nlp_id]                INT            NOT NULL,
    [note_id]                    INT            NOT NULL,
    [section_concept_id]         INT            NULL,
    [snippet]                    VARCHAR (250)  NULL,
    [offset]                     VARCHAR (250)  NULL,
    [lexical_variant]            VARCHAR (250)  NOT NULL,
    [note_nlp_concept_id]        INT            NULL,
    [note_nlp_source_concept_id] INT            NULL,
    [nlp_system]                 VARCHAR (250)  NULL,
    [nlp_date]                   DATE           NOT NULL,
    [nlp_datetime]               DATETIME2 (7)  NULL,
    [term_exists]                VARCHAR (1)    NULL,
    [term_temporal]              VARCHAR (50)   NULL,
    [term_modifiers]             VARCHAR (2000) NULL,
    CONSTRAINT [xpk_note_nlp] PRIMARY KEY NONCLUSTERED ([note_nlp_id] ASC),
    CONSTRAINT [fpk_note_nlp_concept] FOREIGN KEY ([note_nlp_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_note_nlp_note] FOREIGN KEY ([note_id]) REFERENCES [dbo].[note] ([note_id]),
    CONSTRAINT [fpk_note_nlp_section_concept] FOREIGN KEY ([section_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_note_nlp_concept_id]
    ON [dbo].[note_nlp]([note_nlp_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_note_nlp_note_id]
    ON [dbo].[note_nlp]([note_id] ASC);

