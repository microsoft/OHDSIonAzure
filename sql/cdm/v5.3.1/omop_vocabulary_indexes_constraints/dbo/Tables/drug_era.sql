CREATE TABLE [dbo].[drug_era] (
    [drug_era_id]         INT  NOT NULL,
    [person_id]           INT  NOT NULL,
    [drug_concept_id]     INT  NOT NULL,
    [drug_era_start_date] DATE NOT NULL,
    [drug_era_end_date]   DATE NOT NULL,
    [drug_exposure_count] INT  NULL,
    [gap_days]            INT  NULL,
    CONSTRAINT [xpk_drug_era] PRIMARY KEY NONCLUSTERED ([drug_era_id] ASC),
    CONSTRAINT [fpk_drug_era_concept] FOREIGN KEY ([drug_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_era_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_drug_era_concept_id]
    ON [dbo].[drug_era]([drug_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_drug_era_person_id]
    ON [dbo].[drug_era]([person_id] ASC);

