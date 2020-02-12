FROM registry.redhat.io/jboss-webserver-5/webserver52-openjdk11-tomcat9-openshift-rhel7:latest
MAINTAINER Alkacon Software GmbH

#
# This Dockerfile installs a simple OpenCms demo system.
# It downloads the OpenCms distro and installs it with all the standard demo modules.
#
# Use the following command to run:
#
# docker run -d -p 80:8080 -p 22000:22 alkacon/opencms-docker:9.5.3-simple
#
USER root
ENV APP_HOME=/home/app/
ENV APP_USER=app
#ENV APP_GROUP=root
RUN mkdir -p ${APP_HOME}

#RUN groupadd -r ${APP_GROUP} && useradd -r -g ${APP_GROUP} -d ${APP_HOME} -s /sbin/nologin -c "Docker User" ${APP_USER} && chown -R ${APP_USER}:${APP_USER} ${APP_HOME}
RUN useradd -r -g 0 -d ${APP_HOME} -s /sbin/nologin -c "Docker User" ${APP_USER} && chown -R ${APP_USER}:0 ${APP_HOME}

# Variables used in the shell scripts loaded from the file system
ENV TOMCAT_HOME=/opt/jws-5.2/tomcat
ENV TOMCAT_LIB=${TOMCAT_HOME}/lib \
	WEBAPPS_HOME=${TOMCAT_HOME}/webapps \
    OPENCMS_HOME=${TOMCAT_HOME}/webapps/ROOT \
    ARTIFACTS_FOLDER=${APP_HOME}artifacts/ \
    CONFIG_FILE=${APP_HOME}config/setup.properties \
    OPENCMS_URL=http://www.opencms.org/downloads/opencms/opencms-11.0.1.zip \
    OPENCMS_COMPONENTS=workplace,demo \
    UPDATE_CONFIG_FILES="WEB-INF/web.xml WEB-INF/opencms.tld WEB-INF/config/opencms-search.xml WEB-INF/config/opencms-system.xml WEB-INF/config/opencms-vfs.xml WEB-INF/config/opencms-workplace.xml"\
    TIME_ZONE=Europe/Berlin \
    TOMCAT_OPTS="-Xmx1g -Xms512m -server -XX:+UseConcMarkSweepGC" \
    GZIP=true \
	ADMIN_PASSWD=admin \
	DB_HOST=172.17.0.2 \
	DB_NAME=opencmsv6 \
	DB_USER=root \
	DB_PASSWD=toor\
	WEBRESOURCES_CACHE_SIZE=200000\
	DEBUG=false


# Create the setup configuration file
COPY resources ${APP_HOME}

RUN chmod +x ${APP_HOME}root/*.sh && \
    chown -R ${APP_USER}:0 ${TOMCAT_HOME} && \
    chown -R ${APP_USER}:0 ${APP_HOME} && \
    chmod -R g+rw ${TOMCAT_HOME} && \
    chmod -R g+rw ${APP_HOME}
 
USER ${APP_USER}
 
VOLUME ${WEBAPPS_HOME}

RUN bash ${APP_HOME}root/opencms-fetch.sh && \
    rm -rf ${WEBAPPS_HOME}/*

# Expose port 8080 for Tomcat and define the startup script
EXPOSE 8080

CMD ${APP_HOME}root/opencms-run.sh
