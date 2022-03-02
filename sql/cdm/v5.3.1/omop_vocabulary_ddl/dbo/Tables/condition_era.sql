CREATE TABLE [dbo].[condition_era] (
    [condition_era_id]           INT  NOT NULL,
    [person_id]                  INT  NOT NULL,
    [condition_concept_id]       INT  NOT NULL,
    [condition_era_start_date]   DATE NOT NULL,
    [condition_era_end_date]     DATE NOT NULL,
    [condition_occurrence_count] INT  NULL
);

