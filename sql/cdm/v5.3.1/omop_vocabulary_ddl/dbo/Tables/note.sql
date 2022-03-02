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
    [note_source_value]     VARCHAR (50)  NULL
);

