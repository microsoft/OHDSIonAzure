CREATE TABLE [dbo].[dose_era] (
    [dose_era_id]         INT        NOT NULL,
    [person_id]           INT        NOT NULL,
    [drug_concept_id]     INT        NOT NULL,
    [unit_concept_id]     INT        NOT NULL,
    [dose_value]          FLOAT (53) NOT NULL,
    [dose_era_start_date] DATE       NOT NULL,
    [dose_era_end_date]   DATE       NOT NULL
);

