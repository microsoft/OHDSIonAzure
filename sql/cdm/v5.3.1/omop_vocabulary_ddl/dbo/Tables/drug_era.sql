CREATE TABLE [dbo].[drug_era] (
    [drug_era_id]         INT  NOT NULL,
    [person_id]           INT  NOT NULL,
    [drug_concept_id]     INT  NOT NULL,
    [drug_era_start_date] DATE NOT NULL,
    [drug_era_end_date]   DATE NOT NULL,
    [drug_exposure_count] INT  NULL,
    [gap_days]            INT  NULL
);
