CREATE TABLE [dbo].[concept_ancestor] (
    [ancestor_concept_id]      INT NOT NULL,
    [descendant_concept_id]    INT NOT NULL,
    [min_levels_of_separation] INT NOT NULL,
    [max_levels_of_separation] INT NOT NULL
);
