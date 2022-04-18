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
    [invalid_reason]              VARCHAR (1) NULL,
    CONSTRAINT [xpk_drug_strength] PRIMARY KEY NONCLUSTERED ([drug_concept_id] ASC, [ingredient_concept_id] ASC),
    CONSTRAINT [fpk_drug_strength_concept_1] FOREIGN KEY ([drug_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_strength_concept_2] FOREIGN KEY ([ingredient_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_strength_unit_1] FOREIGN KEY ([amount_unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_strength_unit_2] FOREIGN KEY ([numerator_unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_drug_strength_unit_3] FOREIGN KEY ([denominator_unit_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_drug_strength_id_2]
    ON [dbo].[drug_strength]([ingredient_concept_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_drug_strength_id_1]
    ON [dbo].[drug_strength]([drug_concept_id] ASC);

