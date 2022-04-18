CREATE TABLE [dbo].[drug_exposure] (
    [drug_exposure_id]             INT           NOT NULL,
    [person_id]                    INT           NOT NULL,
    [drug_concept_id]              INT           NOT NULL,
    [drug_exposure_start_date]     DATE          NOT NULL,
    [drug_exposure_start_datetime] DATETIME2 (7) NULL,
    [drug_exposure_end_date]       DATE          NOT NULL,
    [drug_exposure_end_datetime]   DATETIME2 (7) NULL,
    [verbatim_end_date]            DATE          NULL,
    [drug_type_concept_id]         INT           NOT NULL,
    [stop_reason]                  VARCHAR (20)  NULL,
    [refills]                      INT           NULL,
    [quantity]                     FLOAT (53)    NULL,
    [days_supply]                  INT           NULL,
    [sig]                          VARCHAR (MAX) NULL,
    [route_concept_id]             INT           NULL,
    [lot_number]                   VARCHAR (50)  NULL,
    [provider_id]                  INT           NULL,
    [visit_occurrence_id]          INT           NULL,
    [visit_detail_id]              INT           NULL,
    [drug_source_value]            VARCHAR (50)  NULL,
    [drug_source_concept_id]       INT           NULL,
    [route_source_value]           VARCHAR (50)  NULL,
    [dose_unit_source_value]       VARCHAR (50)  NULL,
    CONSTRAINT [xpk_drug_exposure] PRIMARY KEY NONCLUSTERED ([drug_exposure_id] ASC),
    CONSTRAINT [fpk_drug_concept] FOREIGN KEY ([drug_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_concept_s] FOREIGN KEY ([drug_source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_person] FOREIGN KEY ([person_id]) REFERENCES [dbo].[person] ([person_id]),
    CONSTRAINT [fpk_drug_provider] FOREIGN KEY ([provider_id]) REFERENCES [dbo].[provider] ([provider_id]),
    CONSTRAINT [fpk_drug_route_concept] FOREIGN KEY ([route_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_type_concept] FOREIGN KEY ([drug_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_visit] FOREIGN KEY ([visit_occurrence_id]) REFERENCES [dbo].[visit_occurrence] ([visit_occurrence_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_drug_visit_id]
    ON [dbo].[drug_exposure]([visit_occurrence_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_drug_concept_id]
    ON [dbo].[drug_exposure]([drug_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_drug_person_id]
    ON [dbo].[drug_exposure]([person_id] ASC);

