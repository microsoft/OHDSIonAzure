CREATE TABLE [dbo].[concept_relationship] (
    [concept_id_1]     INT          NOT NULL,
    [concept_id_2]     INT          NOT NULL,
    [relationship_id]  VARCHAR (20) NOT NULL,
    [valid_start_date] VARCHAR (8)  NOT NULL,
    [valid_end_date]   VARCHAR (8)  NOT NULL,
    [invalid_reason]   VARCHAR (1)  NULL
);

