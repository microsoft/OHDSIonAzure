CREATE TABLE [dbo].[fact_relationship] (
    [domain_concept_id_1]     INT NOT NULL,
    [fact_id_1]               INT NOT NULL,
    [domain_concept_id_2]     INT NOT NULL,
    [fact_id_2]               INT NOT NULL,
    [relationship_concept_id] INT NOT NULL
);
