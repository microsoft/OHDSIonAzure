CREATE TABLE [dbo].[cohort] (
    [cohort_definition_id] INT  NOT NULL,
    [subject_id]           INT  NOT NULL,
    [cohort_start_date]    DATE NOT NULL,
    [cohort_end_date]      DATE NOT NULL,
    CONSTRAINT [xpk_cohort] PRIMARY KEY NONCLUSTERED ([cohort_definition_id] ASC, [subject_id] ASC, [cohort_start_date] ASC, [cohort_end_date] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_cohort_c_definition_id]
    ON [dbo].[cohort]([cohort_definition_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_cohort_subject_id]
    ON [dbo].[cohort]([subject_id] ASC);
