CREATE TABLE [dbo].[source_to_concept_map] (
    [source_code]             VARCHAR (50)  NOT NULL,
    [source_concept_id]       INT           NOT NULL,
    [source_vocabulary_id]    VARCHAR (20)  NOT NULL,
    [source_code_description] VARCHAR (255) NULL,
    [target_concept_id]       INT           NOT NULL,
    [target_vocabulary_id]    VARCHAR (20)  NOT NULL,
    [valid_start_date]        VARCHAR (8)   NOT NULL,
    [valid_end_date]          VARCHAR (8)   NOT NULL,
    [invalid_reason]          VARCHAR (1)   NULL,
    CONSTRAINT [xpk_source_to_concept_map] PRIMARY KEY NONCLUSTERED ([source_vocabulary_id] ASC, [target_concept_id] ASC, [source_code] ASC, [valid_end_date] ASC),
    CONSTRAINT [fpk_source_concept_id] FOREIGN KEY ([source_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_source_to_concept_map_c_1] FOREIGN KEY ([target_concept_id]) REFERENCES [dbo].[concept] ([concept_id]),
    CONSTRAINT [fpk_source_to_concept_map_v_1] FOREIGN KEY ([source_vocabulary_id]) REFERENCES [dbo].[vocabulary] ([vocabulary_id]),
    CONSTRAINT [fpk_source_to_concept_map_v_2] FOREIGN KEY ([target_vocabulary_id]) REFERENCES [dbo].[vocabulary] ([vocabulary_id])
);


GO
CREATE NONCLUSTERED INDEX [idx_source_to_concept_map_code]
    ON [dbo].[source_to_concept_map]([source_code] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_source_to_concept_map_id_2]
    ON [dbo].[source_to_concept_map]([target_vocabulary_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_source_to_concept_map_id_1]
    ON [dbo].[source_to_concept_map]([source_vocabulary_id] ASC);


GO
CREATE CLUSTERED INDEX [idx_source_to_concept_map_id_3]
    ON [dbo].[source_to_concept_map]([target_concept_id] ASC);

