CREATE TABLE [dbo].[dose_era] (
    [dose_era_id]         INT        NOT NULL,
    [person_id]           INT        NOT NULL,
    [drug_concept_id]     INT        NOT NULL,
    [unit_concept_id]     INT        NOT NULL,
    [dose_value]          FLOAT (53) NOT NULL,
    [dose_era_start_date] DATE       NOT NULL,
    [dose_era_end_date]   DATE       NOT NULL,
    CONSTRAINT [xpk_dose_era] PRIMARY KEY NONCLUSTERED ([dose_era_id] ASC),
    CONSTRAINT [fpk_dose_era_concept] FOREIGN KEY ([drug_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_dose_era_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_dose_era_unit_concept] FOREIGN KEY ([unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_dose_era_concept_id]
    ON [dbo].[dose_era]([drug_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_dose_era_person_id]
    ON [dbo].[dose_era]([person_id] ASC);

