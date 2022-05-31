CREATE TABLE [dbo].[concept_synonym] (
    [concept_id]           INT            NOT NULL,
    [concept_synonym_name] VARCHAR (1000) NOT NULL,
    [language_concept_id]  INT            NOT NULL,
    -- CONSTRAINT [fpk_concept_synonym_concept] FOREIGN KEY ([concept_id]) REFERENCES [dbo].[concept] ([concept_id]), -- OMOP Modification, vocabulary conflict
    CONSTRAINT [fpk_concept_synonym_language] FOREIGN KEY ([language_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    -- Taken out in 5.3.2 release https://github.com/OHDSI/CommonDataModel/releases/tag/v5.3.2
    -- CONSTRAINT [uq_concept_synonym] UNIQUE NONCLUSTERED ([concept_id] ASC, [concept_synonym_name] ASC, [language_concept_id] ASC)
);


GO
CREATE CLUSTERED INDEX [idx_concept_synonym_id]
    ON [dbo].[concept_synonym]([concept_id] ASC);
