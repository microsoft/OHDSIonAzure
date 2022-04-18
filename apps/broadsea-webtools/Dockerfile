FROM tomcat:9.0.46-jdk8-openjdk-buster

# OHDSI WebAPI and ATLAS web application running in Tomcat

# expose ports
EXPOSE 8080

# set the WEBAPI_RELEASE environment variable within the Docker container
ENV WEBAPI_RELEASE=2.10.1

# set the ATLAS_RELEASE environment variable within the Docker container
ENV ATLAS_RELEASE=2.10.1

# optionally override the war file url when building this container using: --build-arg WEBAPI_WAR=<webapi war file name>
ARG WEBAPI_WAR=WebAPI-2.9.0.war

# install linux utilities and supervisor daemon
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    supervisor \
    build-essential \
    curl \
    git-core \
    maven \
    python-pip \
    && rm -rf /var/lib/apt/lists/*

# install mysql client
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install mssql-tools unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# Install OpenSSH and set the password for root to "Docker!". In this example, "apk add" is the install instruction for an Alpine Linux-based image.
RUN export DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get -y install --no-install-recommends openssh-server \
&& echo "root:Docker!" | chpasswd

# Copy the sshd_config file to the /etc/ssh/ directory
COPY config/sshd_config /etc/ssh/

# Open port 2222 for SSH access
EXPOSE 80 2222

# install npm and upgrade it to the latest version
WORKDIR ~
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh \
    && chmod +x nodesource_setup.sh \
    && bash nodesource_setup.sh
RUN apt -y install nodejs
RUN node -v
RUN apt-get update && apt-get install -y --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*
RUN npm install -g npm
RUN pip install setuptools
RUN pip install supervisor-stdout

# deploy the OHDSI WEBAPI and OHDSI ATLAS web application to the Tomcat server

# set working directory to the Tomcat server webapps directory
WORKDIR /usr/local/tomcat/webapps

# deploy the released OHDSI WebAPI war file from the OHDSI CI Nexus repository
#ENV WEBAPI_WAR_URL=https://repo.ohdsi.org/nexus/repository/releases/org/ohdsi/WebAPI/$WEBAPI_RELEASE/$WEBAPI_WAR
#RUN wget $WEBAPI_WAR_URL \
#    && mv /usr/local/tomcat/webapps/WebAPI*.war /usr/local/tomcat/webapps/WebAPI.war

# Build OHDSI WebAPI war file from master branch

RUN git clone https://github.com/OHDSI/WebAPI.git /WebAPI
WORKDIR /WebAPI/
# To checkout a specific WebAPI Release version, uncomment below and comment 'RUN git checkout master'.
# You Will need to make sure that variable WEBAPI_RELEASE is set to the desired version/tag for OHDSI WebAPI (line 9)
# RUN git checkout v$WEBAPI_RELEASE
RUN git checkout master
RUN mkdir WebAPIConfig && mv sample_settings.xml WebAPIConfig/settings.xml
RUN mvn clean package -DskipUnitTests -DskipITtests -s WebAPIConfig/settings.xml -P webapi-mssql
RUN mv /WebAPI/target/WebAPI.war /usr/local/tomcat/webapps/WebAPI.war

# set working directory to the Tomcat server webapps directory
WORKDIR /usr/local/tomcat/webapps

# deploy the released OHDSI Atlas web application
RUN wget https://github.com/OHDSI/Atlas/archive/v$ATLAS_RELEASE.zip \
    && unzip /usr/local/tomcat/webapps/v$ATLAS_RELEASE.zip \
    && mv /usr/local/tomcat/webapps/Atlas-$ATLAS_RELEASE /usr/local/tomcat/webapps/atlas \
    && rm -f v$ATLAS_RELEASE.zip

# bundle the OHDSI Atlas code modules
WORKDIR /usr/local/tomcat/webapps/atlas
RUN npm run build

# create directories for optional jdbc drivers and the log files
RUN mkdir -p /tmp/drivers /var/log/supervisor

# install supervisord configuration file
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# install Atlas local configuration file
COPY config/config-local.js /usr/local/tomcat/webapps/atlas/js/

# install Atlas GIS local configuration file
COPY config/config-gis.js /usr/local/tomcat/webapps/atlas/js/

# install the bash shell deploy script that supervisord will run whenever the container is started
COPY scripts/deploy_script.sh /usr/local/tomcat/bin/
RUN chmod +x /usr/local/tomcat/bin/deploy_script.sh

# install the bash shell enable ssh script that supervisord will run whenever the container is started
COPY scripts/enable_ssh.sh /usr/local/tomcat/bin/
RUN chmod +x /usr/local/tomcat/bin/enable_ssh.sh

# run supervisord to execute the deploy script (which also starts the tomcat server)
CMD ["/usr/bin/supervisord"]
