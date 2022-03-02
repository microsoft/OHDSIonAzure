CREATE TABLE [dbo].[cohort_definition] (
    [cohort_definition_id]          INT           NOT NULL,
    [cohort_definition_name]        VARCHAR (255) NOT NULL,
    [cohort_definition_description] VARCHAR (MAX) NULL,
    [definition_type_concept_id]    INT           NOT NULL,
    [cohort_definition_syntax]      VARCHAR (MAX) NULL,
    [subject_concept_id]            INT           NOT NULL,
    [cohort_initiation_date]        DATE          NULL,
    CONSTRAINT [xpk_cohort_definition] PRIMARY KEY NONCLUSTERED ([cohort_definition_id] ASC),
    CONSTRAINT [fpk_cohort_definition_concept] FOREIGN KEY ([definition_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    -- CONSTRAINT [fpk_cohort_subject_concept] FOREIGN KEY ([subject_concept_id]) REFERENCES [dbo].[concept] ([concept_id]) -- OMOP Modification: remove for conflict with vocabulary
);


GO
CREATE CLUSTERED INDEX [idx_cohort_definition_id]
    ON [dbo].[cohort_definition]([cohort_definition_id] ASC);

