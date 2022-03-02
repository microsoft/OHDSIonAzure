CREATE TABLE [dbo].[location] (
    [location_id]           INT          NOT NULL,
    [address_1]             VARCHAR (50) NULL,
    [address_2]             VARCHAR (50) NULL,
    [city]                  VARCHAR (50) NULL,
    [state]                 VARCHAR (2)  NULL,
    [zip]                   VARCHAR (9)  NULL,
    [county]                VARCHAR (20) NULL,
    [location_source_value] VARCHAR (50) NULL,
    CONSTRAINT [xpk_location] PRIMARY KEY NONCLUSTERED ([location_id] ASC)
);

