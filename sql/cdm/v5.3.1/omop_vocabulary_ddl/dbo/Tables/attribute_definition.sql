CREATE TABLE [dbo].[attribute_definition] (
    [attribute_definition_id]   INT           NOT NULL,
    [attribute_name]            VARCHAR (255) NOT NULL,
    [attribute_description]     VARCHAR (MAX) NULL,
    [attribute_type_concept_id] INT           NOT NULL,
    [attribute_syntax]          VARCHAR (MAX) NULL
);

