CREATE TABLE [dbo].[cohort_attribute] (
    [cohort_definition_id]    INT        NOT NULL,
    [subject_id]              INT        NOT NULL,
    [cohort_start_date]       DATE       NOT NULL,
    [cohort_end_date]         DATE       NOT NULL,
    [attribute_definition_id] INT        NOT NULL,
    [value_as_number]         FLOAT (53) NULL,
    [value_as_concept_id]     INT        NULL
);

