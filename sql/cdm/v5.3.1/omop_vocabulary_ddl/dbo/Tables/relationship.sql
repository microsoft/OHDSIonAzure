CREATE TABLE [dbo].[relationship] (
    [relationship_id]         VARCHAR (20)  NOT NULL,
    [relationship_name]       VARCHAR (255) NOT NULL,
    [is_hierarchical]         VARCHAR (1)   NOT NULL,
    [defines_ancestry]        VARCHAR (1)   NOT NULL,
    [reverse_relationship_id] VARCHAR (20)  NOT NULL,
    [relationship_concept_id] INT           NOT NULL
);

