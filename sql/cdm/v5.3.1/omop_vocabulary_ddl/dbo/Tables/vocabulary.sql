CREATE TABLE [dbo].[vocabulary] (
    [vocabulary_id]         VARCHAR (20)  NOT NULL,
    [vocabulary_name]       VARCHAR (255) NOT NULL,
    [vocabulary_reference]  VARCHAR (255) NOT NULL,
    [vocabulary_version]    VARCHAR (255) NULL,
    [vocabulary_concept_id] INT           NOT NULL
);
