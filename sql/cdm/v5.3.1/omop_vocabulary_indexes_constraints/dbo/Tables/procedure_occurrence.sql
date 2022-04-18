CREATE TABLE [dbo].[procedure_occurrence] (
    [procedure_occurrence_id]     INT           NOT NULL,
    [person_id]                   INT           NOT NULL,
    [procedure_concept_id]        INT           NOT NULL,
    [procedure_date]              DATE          NOT NULL,
    [procedure_datetime]          DATETIME2 (7) NULL,
    [procedure_type_concept_id]   INT           NOT NULL,
    [modifier_concept_id]         INT           NULL,
    [quantity]                    INT           NULL,
    [provider_id]                 INT           NULL,
    [visit_occurrence_id]         INT           NULL,
    [visit_detail_id]             INT           NULL,
    [procedure_source_value]      VARCHAR (50)  NULL,
    [procedure_source_concept_id] INT           NULL,
    [modifier_source_value]       VARCHAR (50)  NULL,
    CONSTRAINT [xpk_procedure_occurrence] PRIMARY KEY NONCLUSTERED ([procedure_occurrence_id] ASC),
    CONSTRAINT [fpk_procedure_concept] FOREIGN KEY ([procedure_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_procedure_concept_s] FOREIGN KEY ([procedure_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_procedure_modifier] FOREIGN KEY ([modifier_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_procedure_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_procedure_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_procedure_type_concept] FOREIGN KEY ([procedure_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_procedure_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_visit_id]
    ON [dbo].[procedure_occurrence]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_concept_id]
    ON [dbo].[procedure_occurrence]([procedure_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_procedure_person_id]
    ON [dbo].[procedure_occurrence]([person_id] ASC);

