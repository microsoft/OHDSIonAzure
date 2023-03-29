CREATE TABLE [dbo].[care_site] (
    [care_site_id]                  INT           NOT NULL,
    [care_site_name]                VARCHAR (255) NULL,
    [place_of_service_concept_id]   INT           NULL,
    [location_id]                   INT           NULL,
    [care_site_source_value]        VARCHAR (50)  NULL,
    [place_of_service_source_value] VARCHAR (50)  NULL,
    CONSTRAINT [xpk_care_site] PRIMARY KEY NONCLUSTERED ([care_site_id] ASC),
    CONSTRAINT [fpk_care_site_location] FOREIGN KEY ([location_id]) REFERENCES [dbo].[location] ([location_id]),
    CONSTRAINT [fpk_care_site_place] FOREIGN KEY ([place_of_service_concept_id]) REFERENCES [dbo].[concept] ([concept_id])
);
