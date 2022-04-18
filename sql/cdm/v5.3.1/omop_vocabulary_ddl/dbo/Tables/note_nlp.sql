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
    [term_modifiers]             VARCHAR (2000) NULL
);

