FROM rocker/tidyverse

RUN apt-get update && apt-get install -y python-dev openjdk-8-jdk liblzma-dev libbz2-dev \
&& R CMD javareconf

## Install Rserve
RUN install2.r \
	Rserve \
	RSclient \
	openssl \
	httr \
	xml2 \
	remotes \
&& rm -rf /tmp/download_packages/ /tmp/*.rds

## TODO - Download and unzip jdbc drivers and delete after COPY step.
# https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server?view=sql-server-ver15

## Copy JDBC Drivers
COPY jdbc_drivers /home/jdbc_drivers

## Install OHDSI R packages
# TODO: Switch to original master once fixes are merged. Or move code base into AzDo.
#       https://github.com/OHDSI/ETL-Synthea/pull/100
# Error seen with original master: Unsupported CDM specified. Supported CDM versions are "5.3" and "5.4"
# Using OHDSI/ETL-Synthea@a58bfd32715a05f8031790c98d35888e02af17b5 until original master is stabilized
RUN installGithub.r \
	OHDSI/Achilles \
	OHDSI/ETL-Synthea@a58bfd32715a05f8031790c98d35888e02af17b5 \
&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

CMD ["Rscript"]
