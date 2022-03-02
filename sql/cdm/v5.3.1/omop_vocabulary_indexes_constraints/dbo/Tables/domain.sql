CREATE TABLE [dbo].[domain] (
    [domain_id]         VARCHAR (20)  NOT NULL,
    [domain_name]       VARCHAR (255) NOT NULL,
    [domain_concept_id] INT           NOT NULL,
    CONSTRAINT [xpk_domain] PRIMARY KEY NONCLUSTERED ([domain_id] ASC),
    CONSTRAINT [fpk_domain_concept] FOREIGN KEY ([domain_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_domain_domain_id]
    ON [dbo].[domain]([domain_id] ASC);

