CREATE TABLE [dbo].[visit_occurrence] (
    [visit_occurrence_id]           INT           NOT NULL,
    [person_id]                     INT           NOT NULL,
    [visit_concept_id]              INT           NOT NULL,
    [visit_start_date]              DATE          NOT NULL,
    [visit_start_datetime]          DATETIME2 (7) NULL,
    [visit_end_date]                DATE          NOT NULL,
    [visit_end_datetime]            DATETIME2 (7) NULL,
    [visit_type_concept_id]         INT           NOT NULL,
    [provider_id]                   INT           NULL,
    [care_site_id]                  INT           NULL,
    [visit_source_value]            VARCHAR (50)  NULL,
    [visit_source_concept_id]       INT           NULL,
    [admitting_source_concept_id]   INT           NULL,
    [admitting_source_value]        VARCHAR (50)  NULL,
    [discharge_to_concept_id]       INT           NULL,
    [discharge_to_source_value]     VARCHAR (50)  NULL,
    [preceding_visit_occurrence_id] INT           NULL,
    CONSTRAINT [xpk_visit_occurrence] PRIMARY KEY NONCLUSTERED ([visit_occurrence_id] ASC),
    CONSTRAINT [fpk_visit_admitting_s] FOREIGN KEY ([admitting_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_visit_care_site] FOREIGN KEY ([care_site_id]) REFERENCES [dbo].[care_site] ([care_site_id]),
    CONSTRAINT [fpk_visit_concept_s] FOREIGN KEY ([visit_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_visit_discharge] FOREIGN KEY ([discharge_to_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_visit_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_visit_preceding] FOREIGN KEY ([preceding_visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id]),
    CONSTRAINT [fpk_visit_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_visit_type_concept] FOREIGN KEY ([visit_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_visit_concept_id]
    ON [dbo].[visit_occurrence]([visit_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_visit_person_id]
    ON [dbo].[visit_occurrence]([person_id] ASC);
