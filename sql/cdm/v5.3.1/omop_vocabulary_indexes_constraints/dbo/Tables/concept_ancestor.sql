CREATE TABLE [dbo].[concept_ancestor] (
    [ancestor_concept_id]      INT NOT NULL,
    [descendant_concept_id]    INT NOT NULL,
    [min_levels_of_separation] INT NOT NULL,
    [max_levels_of_separation] INT NOT NULL,
    CONSTRAINT [xpk_concept_ancestor] PRIMARY KEY NONCLUSTERED ([ancestor_concept_id] ASC, [descendant_concept_id] ASC),
    -- CONSTRAINT [fpk_concept_ancestor_concept_1] FOREIGN KEY ([ancestor_concept_id]) REFERENCES [dbo].[concept] ([concept_id]), -- OMOP Modification: removed because of conflicts with Athena Vocabulary
    -- CONSTRAINT [fpk_concept_ancestor_concept_2] FOREIGN KEY ([descendant_concept_id]) REFERENCES [dbo].[concept] ([concept_id]) -- OMOP Modification: removed because of conflicts with Athena Vocabulary
);


GO
CREATE NONCLUSTERED INDEX [idx_concept_ancestor_id_2]
    ON [dbo].[concept_ancestor]([descendant_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_concept_ancestor_id_1]
    ON [dbo].[concept_ancestor]([ancestor_concept_id] ASC);

