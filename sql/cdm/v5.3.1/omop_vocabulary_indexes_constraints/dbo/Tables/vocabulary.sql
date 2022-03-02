CREATE TABLE [dbo].[vocabulary] (
    [vocabulary_id]         VARCHAR (20)  NOT NULL,
    [vocabulary_name]       VARCHAR (255) NOT NULL,
    [vocabulary_reference]  VARCHAR (255) NOT NULL,
    [vocabulary_version]    VARCHAR (255) NULL,
    [vocabulary_concept_id] INT           NOT NULL,
    CONSTRAINT [xpk_vocabulary] PRIMARY KEY NONCLUSTERED ([vocabulary_id] ASC),
    CONSTRAINT [fpk_vocabulary_concept] FOREIGN KEY ([vocabulary_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_vocabulary_vocabulary_id]
    ON [dbo].[vocabulary]([vocabulary_id] ASC);

