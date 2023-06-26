CREATE TABLE ${OMOP_RESULTS_SCHEMA_NAME}.[achilles_analysis]
( 
	[analysis_id] [int]  NULL,
	[analysis_name] [nvarchar](255)  NULL,
	[stratum_1_name] [nvarchar](255)  NULL,
	[stratum_2_name] [nvarchar](255)  NULL,
	[stratum_3_name] [nvarchar](255)  NULL,
	[stratum_4_name] [nvarchar](255)  NULL,
	[stratum_5_name] [nvarchar](255)  NULL,
	[is_default] [int]  NULL,
	[category] [nvarchar](255)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO

CREATE TABLE ${OMOP_RESULTS_SCHEMA_NAME}.[achilles_results]
( 
	[analysis_id] [int]  NULL,
	[stratum_1] [nvarchar](max)  NULL,
	[stratum_2] [nvarchar](max)  NULL,
	[stratum_3] [nvarchar](max)  NULL,
	[stratum_4] [nvarchar](max)  NULL,
	[stratum_5] [nvarchar](max)  NULL,
	[count_value] [bigint]  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO

CREATE TABLE ${OMOP_RESULTS_SCHEMA_NAME}.[achilles_results_dist]
( 
	[analysis_id] [int]  NULL,
	[stratum_1] [nvarchar](max)  NULL,
	[stratum_2] [nvarchar](max)  NULL,
	[stratum_3] [nvarchar](max)  NULL,
	[stratum_4] [nvarchar](max)  NULL,
	[stratum_5] [nvarchar](max)  NULL,
	[count_value] [bigint]  NULL,
	[min_value] [decimal](38,0)  NULL,
	[max_value] [decimal](38,0)  NULL,
	[avg_value] [decimal](38,0)  NULL,
	[stdev_value] [decimal](38,0)  NULL,
	[median_value] [decimal](38,0)  NULL,
	[p10_value] [decimal](38,0)  NULL,
	[p25_value] [decimal](38,0)  NULL,
	[p75_value] [decimal](38,0)  NULL,
	[p90_value] [decimal](38,0)  NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO