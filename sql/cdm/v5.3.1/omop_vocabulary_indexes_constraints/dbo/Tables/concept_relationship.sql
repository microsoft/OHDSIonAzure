CREATE TABLE [dbo].[concept_relationship] (
    [concept_id_1]     INT          NOT NULL,
    [concept_id_2]     INT          NOT NULL,
    [relationship_id]  VARCHAR (20) NOT NULL,
    [valid_start_date] VARCHAR (8)  NOT NULL,
    [valid_end_date]   VARCHAR (8)  NOT NULL,
    [invalid_reason]   VARCHAR (1)  NULL,
    CONSTRAINT [xpk_concept_relationship] PRIMARY KEY NONCLUSTERED ([concept_id_1] ASC, [concept_id_2] ASC, [relationship_id] ASC),
    -- CONSTRAINT [fpk_concept_relationship_c_1] FOREIGN KEY ([concept_id_1]) REFERENCES [dbo].[concept] ([concept_id]), -- OMOP Modification: removed because of conflicts with Athena Vocabulary
    -- CONSTRAINT [fpk_concept_relationship_c_2] FOREIGN KEY ([concept_id_2]) REFERENCES [dbo].[concept] ([concept_id]), -- OMOP Modification: removed because of conflicts with Athena Vocabulary
    CONSTRAINT [fpk_concept_relationship_id] FOREIGN KEY ([relationship_id]) REFERENCES [dbo].[relationship] ([relationship_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_concept_relationship_id_3]
    ON [dbo].[concept_relationship]([relationship_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_concept_relationship_id_2]
    ON [dbo].[concept_relationship]([concept_id_2] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_concept_relationship_id_1]
    ON [dbo].[concept_relationship]([concept_id_1] ASC);

