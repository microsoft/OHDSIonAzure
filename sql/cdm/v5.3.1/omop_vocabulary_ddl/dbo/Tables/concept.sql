CREATE TABLE [dbo].[concept] (
    [concept_id]       INT           NOT NULL,
    [concept_name]     VARCHAR (2000) NOT NULL, -- OMOP Expansion for vocabulary
    [domain_id]        VARCHAR (20)  NOT NULL,
    [vocabulary_id]    VARCHAR (20)  NOT NULL,
    [concept_class_id] VARCHAR (20)  NOT NULL,
    [standard_concept] VARCHAR (1)   NULL,
    [concept_code]     VARCHAR (50)  NOT NULL,
    [valid_start_date] VARCHAR (8)   NOT NULL,
    [valid_end_date]   VARCHAR (8)   NOT NULL,
    [invalid_reason]   VARCHAR (1)   NULL
);

