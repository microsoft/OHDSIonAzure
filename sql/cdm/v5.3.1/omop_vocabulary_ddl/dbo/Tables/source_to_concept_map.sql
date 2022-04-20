CREATE TABLE [dbo].[source_to_concept_map] (
    [source_code]             VARCHAR (50)  NOT NULL,
    [source_concept_id]       INT           NOT NULL,
    [source_vocabulary_id]    VARCHAR (20)  NOT NULL,
    [source_code_description] VARCHAR (255) NULL,
    [target_concept_id]       INT           NOT NULL,
    [target_vocabulary_id]    VARCHAR (20)  NOT NULL,
    [valid_start_date]        VARCHAR (8)   NOT NULL,
    [valid_end_date]          VARCHAR (8)   NOT NULL,
    [invalid_reason]          VARCHAR (1)   NULL
);
