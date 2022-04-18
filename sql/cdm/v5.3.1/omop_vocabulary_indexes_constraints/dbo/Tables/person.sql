CREATE TABLE [dbo].[person] (
    [person_id]                   INT           NOT NULL,
    [gender_concept_id]           INT           NOT NULL,
    [year_of_birth]               INT           NOT NULL,
    [month_of_birth]              INT           NULL,
    [day_of_birth]                INT           NULL,
    [birth_datetime]              DATETIME2 (7) NULL,
    [race_concept_id]             INT           NOT NULL,
    [ethnicity_concept_id]        INT           NOT NULL,
    [location_id]                 INT           NULL,
    [provider_id]                 INT           NULL,
    [care_site_id]                INT           NULL,
    [person_source_value]         VARCHAR (50)  NULL,
    [gender_source_value]         VARCHAR (50)  NULL,
    [gender_source_concept_id]    INT           NULL,
    [race_source_value]           VARCHAR (50)  NULL,
    [race_source_concept_id]      INT           NULL,
    [ethnicity_source_value]      VARCHAR (50)  NULL,
    [ethnicity_source_concept_id] INT           NULL,
    CONSTRAINT [xpk_person] PRIMARY KEY NONCLUSTERED ([person_id] ASC),
    CONSTRAINT [fpk_person_care_site] FOREIGN KEY ([care_site_id]) REFERENCES [dbo].[care_site] ([care_site_id]),
    CONSTRAINT [fpk_person_ethnicity_concept] FOREIGN KEY ([ethnicity_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_person_ethnicity_concept_s] FOREIGN KEY ([ethnicity_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_person_gender_concept] FOREIGN KEY ([gender_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_person_gender_concept_s] FOREIGN KEY ([gender_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_person_location] FOREIGN KEY ([location_id]) REFERENCES [dbo].[location] ([location_id]),
    CONSTRAINT [fpk_person_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_person_race_concept] FOREIGN KEY ([race_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_person_race_concept_s] FOREIGN KEY ([race_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_person_id]
    ON [dbo].[person]([person_id] ASC);

