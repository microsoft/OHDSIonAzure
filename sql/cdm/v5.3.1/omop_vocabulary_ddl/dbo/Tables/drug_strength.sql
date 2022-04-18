CREATE TABLE [dbo].[drug_strength] (
    [drug_concept_id]             INT         NOT NULL,
    [ingredient_concept_id]       INT         NOT NULL,
    [amount_value]                FLOAT (53)  NULL,
    [amount_unit_concept_id]      INT         NULL,
    [numerator_value]             FLOAT (53)  NULL,
    [numerator_unit_concept_id]   INT         NULL,
    [denominator_value]           FLOAT (53)  NULL,
    [denominator_unit_concept_id] INT         NULL,
    [box_size]                    INT         NULL,
    [valid_start_date]            VARCHAR (8) NOT NULL,
    [valid_end_date]              VARCHAR (8) NOT NULL,
    [invalid_reason]              VARCHAR (1) NULL
);

