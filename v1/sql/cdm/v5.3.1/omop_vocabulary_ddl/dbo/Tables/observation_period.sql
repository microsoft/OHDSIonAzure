CREATE TABLE [dbo].[observation_period] (
    [observation_period_id]         INT  NOT NULL,
    [person_id]                     INT  NOT NULL,
    [observation_period_start_date] DATE NOT NULL,
    [observation_period_end_date]   DATE NOT NULL,
    [period_type_concept_id]        INT  NOT NULL
);
