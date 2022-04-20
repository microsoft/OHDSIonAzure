CREATE TABLE [dbo].[attribute_definition] (
    [attribute_definition_id]   INT           NOT NULL,
    [attribute_name]            VARCHAR (255) NOT NULL,
    [attribute_description]     VARCHAR (MAX) NULL,
    [attribute_type_concept_id] INT           NOT NULL,
    [attribute_syntax]          VARCHAR (MAX) NULL,
    CONSTRAINT [xpk_attribute_definition] PRIMARY KEY NONCLUSTERED ([attribute_definition_id] ASC),
    CONSTRAINT [fpk_attribute_type_concept] FOREIGN KEY ([attribute_type_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE CLUSTERED INDEX [idx_attribute_definition_id]
    ON [dbo].[attribute_definition]([attribute_definition_id] ASC);
