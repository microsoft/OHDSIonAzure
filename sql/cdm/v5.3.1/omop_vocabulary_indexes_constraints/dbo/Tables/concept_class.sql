CREATE TABLE [dbo].[concept_class] (
    [concept_class_id]         VARCHAR (20)  NOT NULL,
    [concept_class_name]       VARCHAR (255) NOT NULL,
    [concept_class_concept_id] INT           NOT NULL,
    CONSTRAINT [xpk_concept_class] PRIMARY KEY NONCLUSTERED ([concept_class_id] ASC),
    CONSTRAINT [fpk_concept_class_concept] FOREIGN KEY ([concept_class_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE UNIQUE CLUSTERED INDEX [idx_concept_class_class_id]
    ON [dbo].[concept_class]([concept_class_id] ASC);
