#!/bin/bash
if [ ! -d ${ARTIFACTS_FOLDER}libs ]; then
	mkdir -v -p ${ARTIFACTS_FOLDER}libs
fi

echo "Writing properties file to contain list of JARs used by the OpenCms core, to be used in later updates."
JAR_NAMES=$( zipinfo -1 ${ARTIFACTS_FOLDER}opencms.war *.jar | tr '\n' ',' )
JAR_NAMES_PROPERTIES="OPENCMS_CORE_LIBS=$JAR_NAMES"
JAR_NAMES_PROPERTIES_FILE=${ARTIFACTS_FOLDER}libs/core-libs.properties
echo "$JAR_NAMES_PROPERTIES" > $JAR_NAMES_PROPERTIES_FILE

echo "make ${OPENCMS_HOME}"
if [ ! -d ${OPENCMS_HOME} ]; then
	mkdir -v -p ${OPENCMS_HOME}
fi

echo ""
echo "---------------------------------------"
ls -la ${APP_HOME}data/
echo "---------------------------------------"
echo ""
echo "make dir"
if [ ! -d ${APP_HOME}data/WEB-INF/ ]; then
	mkdir -v -p ${APP_HOME}data/WEB-INF/
fi
echo "---- WEB-INF"

echo "link to volume"
ln -s ${APP_HOME}data/WEB-INF/ ${OPENCMS_HOME}/
echo "---- lib"

echo ""
echo "---------------------------------------"
id
echo "---------------------------------------"
echo ""

echo ""
echo "---------------------------------------"
ls -la ${APP_HOME}data
ls -la ${APP_HOME}data/WEB-INF/
echo "---------------------------------------"
echo ""

echo ""
echo "---------------------------------------"
ls -la ${OPENCMS_HOME}/WEB-INF/lib/opencms.jar
echo "---------------------------------------"
echo ""

if [ -f "${OPENCMS_HOME}/WEB-INF/lib/opencms.jar" ]
then
	echo "Opencms installed"
else
	echo "OpenCms not installed yet, running setup"
	if [ ! -d ${WEBAPPS_HOME} ]; then
		mkdir -v -p ${WEBAPPS_HOME}
	fi

	if [ ! -d ${OPENCMS_HOME} ]; then
		mkdir -v -p ${OPENCMS_HOME}
	fi
	
	echo "--------------------------"
	echo "ls ${OPENCMS_HOME}"
	ls -la ${OPENCMS_HOME}
	echo "--------------------------"

	echo "Unzip the .war"
	unzip -q -d ${OPENCMS_HOME} ${ARTIFACTS_FOLDER}opencms.war
	mv ${ARTIFACTS_FOLDER}libs/core-libs.properties ${OPENCMS_HOME}/WEB-INF/lib
	if [ ! -z "$ADMIN_PASSWD" ]; then
		echo "Changing Admin password for setup"
		sed -i -- "s/login \"Admin\" \"admin\"/login \"Admin\" \"admin\"\nsetPassword \"Admin\" \"$ADMIN_PASSWD\"\nlogin \"Admin\" \"$ADMIN_PASSWD\"/g" "${OPENCMS_HOME}/WEB-INF/setupdata/cmssetup.txt"
	fi
	echo "Install OpenCms using org.opencms.setup.CmsAutoSetup with properties \"${CONFIG_FILE}\"" && \
	java -classpath "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:${TOMCAT_LIB}/*" org.opencms.setup.CmsAutoSetup -path ${CONFIG_FILE}

	echo "Deleting no longer  used files"
	rm -rf ${OPENCMS_HOME}/setup
	rm -rf ${OPENCMS_HOME}/WEB-INF/packages/modules/*.zip
	
fi

echo "Deleting artifacts folder"
rm -rf ${ARTIFACTS_FOLDER}
rm -rf ${OPENCMS_HOME}/setup
