CREATE TABLE [dbo].[concept] (
    [concept_id]       INT           NOT NULL,
    [concept_name]     VARCHAR (2000) NOT NULL, -- OMOP Expansion for vocabulary
    [domain_id]        VARCHAR (20)  NOT NULL,
    [vocabulary_id]    VARCHAR (20)  NOT NULL,
    [concept_class_id] VARCHAR (20)  NOT NULL,
    [standard_concept] VARCHAR (1)   NULL,
    [concept_code]     VARCHAR (50)  NOT NULL,
    [valid_start_date] VARCHAR (8)   NOT NULL,
    [valid_end_date]   VARCHAR (8)   NOT NULL,
    [invalid_reason]   VARCHAR (1)   NULL,
    CONSTRAINT [xpk_concept] PRIMARY KEY NONCLUSTERED ([concept_id] ASC),
    CONSTRAINT [fpk_concept_class] FOREIGN KEY ([concept_class_id]) REFERENCES [dbo].[concept_class] ([concept_class_id]),
    CONSTRAINT [fpk_concept_domain] FOREIGN KEY ([domain_id]) REFERENCES [dbo].[domain] ([domain_id]),
    CONSTRAINT [fpk_concept_vocabulary] FOREIGN KEY ([vocabulary_id]) REFERENCES [dbo].[vocabulary] ([vocabulary_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_concept_class_id]
    ON [dbo].[concept]([concept_class_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_concept_domain_id]
    ON [dbo].[concept]([domain_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_concept_vocabluary_id]
    ON [dbo].[concept]([vocabulary_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_concept_code]
    ON [dbo].[concept]([concept_code] ASC);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_concept_concept_id]
    ON [dbo].[concept]([concept_id] ASC);

