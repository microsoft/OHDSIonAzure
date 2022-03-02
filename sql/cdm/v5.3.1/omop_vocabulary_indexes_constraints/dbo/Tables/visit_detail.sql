CREATE TABLE [dbo].[visit_detail] (
    [visit_detail_id]                INT           NOT NULL,
    [person_id]                      INT           NOT NULL,
    [visit_detail_concept_id]        INT           NOT NULL,
    [visit_detail_start_date]        DATE          NOT NULL,
    [visit_detail_start_datetime]    DATETIME2 (7) NULL,
    [visit_detail_end_date]          DATE          NOT NULL,
    [visit_detail_end_datetime]      DATETIME2 (7) NULL,
    [visit_detail_type_concept_id]   INT           NOT NULL,
    [provider_id]                    INT           NULL,
    [care_site_id]                   INT           NULL,
    [admitting_source_concept_id]    INT           NULL,
    [discharge_to_concept_id]        INT           NULL,
    [preceding_visit_detail_id]      INT           NULL,
    [visit_detail_source_value]      VARCHAR (50)  NULL,
    [visit_detail_source_concept_id] INT           NULL,
    [admitting_source_value]         VARCHAR (50)  NULL,
    [discharge_to_source_value]      VARCHAR (50)  NULL,
    [visit_detail_parent_id]         INT           NULL,
    [visit_occurrence_id]            INT           NOT NULL,
    CONSTRAINT [xpk_visit_detail] PRIMARY KEY NONCLUSTERED ([visit_detail_id] ASC),
    CONSTRAINT [fpd_v_detail_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id]),
    CONSTRAINT [fpk_v_detail_admitting_s] FOREIGN KEY ([admitting_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_v_detail_care_site] FOREIGN KEY ([care_site_id]) REFERENCES [dbo].[care_site] ([care_site_id]),
    CONSTRAINT [fpk_v_detail_concept_s] FOREIGN KEY ([visit_detail_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_v_detail_discharge] FOREIGN KEY ([discharge_to_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_v_detail_parent] FOREIGN KEY ([visit_detail_parent_id]) REFERENCES [dbo].[visit_detail] ([visit_detail_id]),
    CONSTRAINT [fpk_v_detail_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_v_detail_preceding] FOREIGN KEY ([preceding_visit_detail_id]) REFERENCES [dbo].[visit_detail] ([visit_detail_id]),
    CONSTRAINT [fpk_v_detail_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_v_detail_type_concept] FOREIGN KEY ([visit_detail_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_visit_detail_concept_id]
    ON [dbo].[visit_detail]([visit_detail_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_visit_detail_person_id]
    ON [dbo].[visit_detail]([person_id] ASC);

