CREATE TABLE [dbo].[cohort_attribute] (
    [cohort_definition_id]    INT        NOT NULL,
    [subject_id]              INT        NOT NULL,
    [cohort_start_date]       DATE       NOT NULL,
    [cohort_end_date]         DATE       NOT NULL,
    [attribute_definition_id] INT        NOT NULL,
    [value_as_number]         FLOAT (53) NULL,
    [value_as_concept_id]     INT        NULL,
    CONSTRAINT [xpk_cohort_attribute] PRIMARY KEY NONCLUSTERED ([cohort_definition_id] ASC, [subject_id] ASC, [cohort_start_date] ASC, [cohort_end_date] ASC, [attribute_definition_id] ASC),
    CONSTRAINT [fpk_ca_attribute_definition] FOREIGN KEY ([attribute_definition_id]) REFERENCES [dbo].[attribute_definition] ([attribute_definition_id]),
    CONSTRAINT [fpk_ca_cohort_definition] FOREIGN KEY ([cohort_definition_id]) REFERENCES [dbo].[cohort_definition] ([cohort_definition_id]),
    CONSTRAINT [fpk_ca_value] FOREIGN KEY ([value_as_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_ca_definition_id]
    ON [dbo].[cohort_attribute]([cohort_definition_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ca_subject_id]
    ON [dbo].[cohort_attribute]([subject_id] ASC);

