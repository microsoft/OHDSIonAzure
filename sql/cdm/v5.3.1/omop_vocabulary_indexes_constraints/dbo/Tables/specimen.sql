CREATE TABLE [dbo].[specimen] (
    [specimen_id]                 INT           NOT NULL,
    [person_id]                   INT           NOT NULL,
    [specimen_concept_id]         INT           NOT NULL,
    [specimen_type_concept_id]    INT           NOT NULL,
    [specimen_date]               DATE          NOT NULL,
    [specimen_datetime]           DATETIME2 (7) NULL,
    [quantity]                    FLOAT (53)    NULL,
    [unit_concept_id]             INT           NULL,
    [anatomic_site_concept_id]    INT           NULL,
    [disease_status_concept_id]   INT           NULL,
    [specimen_source_id]          VARCHAR (50)  NULL,
    [specimen_source_value]       VARCHAR (50)  NULL,
    [unit_source_value]           VARCHAR (50)  NULL,
    [anatomic_site_source_value]  VARCHAR (50)  NULL,
    [disease_status_source_value] VARCHAR (50)  NULL,
    CONSTRAINT [xpk_specimen] PRIMARY KEY NONCLUSTERED ([specimen_id] ASC),
    CONSTRAINT [fpk_specimen_concept] FOREIGN KEY ([specimen_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_specimen_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_specimen_site_concept] FOREIGN KEY ([anatomic_site_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_specimen_status_concept] FOREIGN KEY ([disease_status_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_specimen_type_concept] FOREIGN KEY ([specimen_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_specimen_unit_concept] FOREIGN KEY ([unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_specimen_concept_id]
    ON [dbo].[specimen]([specimen_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_specimen_person_id]
    ON [dbo].[specimen]([person_id] ASC);

