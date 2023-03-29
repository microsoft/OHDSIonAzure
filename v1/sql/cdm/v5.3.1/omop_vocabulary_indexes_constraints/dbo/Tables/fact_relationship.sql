CREATE TABLE [dbo].[fact_relationship] (
    [domain_concept_id_1]     INT NOT NULL,
    [fact_id_1]               INT NOT NULL,
    [domain_concept_id_2]     INT NOT NULL,
    [fact_id_2]               INT NOT NULL,
    [relationship_concept_id] INT NOT NULL,
    CONSTRAINT [fpk_fact_domain_1] FOREIGN KEY ([domain_concept_id_1]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_fact_domain_2] FOREIGN KEY ([domain_concept_id_2]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_fact_relationship] FOREIGN KEY ([relationship_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_fact_relationship_id_3]
    ON [dbo].[fact_relationship]([relationship_concept_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_fact_relationship_id_2]
    ON [dbo].[fact_relationship]([domain_concept_id_2] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_fact_relationship_id_1]
    ON [dbo].[fact_relationship]([domain_concept_id_1] ASC);
