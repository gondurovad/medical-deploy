#!/bin/bash

function build_basic_images() {
  JAR_FILE=$1
  APP_NAME=$2

  docker build -f ./build-scripts/docker/basic/Dockerfile \
    --build-arg JAR_FILE=${JAR_FILE} \
    -t ${APP_NAME}:latest \
    -t ${APP_NAME}:simple .
}

function build_jar() {
  # Get count of args
for var in $@
  do
    DIR=$var
    echo "Building JAR files for ${DIR}"
    CD_PATH="./${DIR}"
    cd ${CD_PATH}
    mvn clean package -T 3 -DskipTests
    cd ..
  done
}

function build_lib() {
  # Get count of args
for var in $@
  do
    DIR=$var
    echo "Building JAR files for ${DIR}"
    CD_PATH="./${DIR}"
    cd ${CD_PATH}
    mvn clean install -T 3 -DskipTests
    cd ..
  done
}

function pull_or_clone_proj() {
  SERVICE_NAME=$1
  SERVICE_URL=$2
 if cd ${SERVICE_NAME}
  then
 #  git branch -f master origin/master
   git checkout dev
   git pull
   cd ..
  else
    git clone --branch dev ${SERVICE_URL} ${SERVICE_NAME}
 fi
}

# Building the app
cd ..

# Clone or update projects
pull_or_clone_proj common-module https://github.com/gondurovad/liga-common-module.git
pull_or_clone_proj medical-monitoring https://github.com/gondurovad/liga-medical-clinic.git
pull_or_clone_proj message-analyzer https://github.com/gondurovad/liga-message-analyzer.git
pull_or_clone_proj person-service https://github.com/gondurovad/liga-person-service.git
pull_or_clone_proj queue-consumer https://github.com/gondurovad/liga-queue-consumer.git


build_lib common-module message-analyzer medical-monitoring
build_jar person-service queue-consumer


APP_VERSION=0.0.1-SNAPSHOT

echo "Building Docker images"
build_basic_images ./medical-monitoring/core/target/medical-monitoring-${APP_VERSION}.jar application/medical-monitoring
build_basic_images ./message-analyzer/core/target/message-analyzer-${APP_VERSION}.jar application/message-analyzer
build_basic_images ./person-service/core/target/person-service-${APP_VERSION}.jar application/person-service
build_basic_images ./queue-consumer/target/queue-consumer-${APP_VERSION}.jar application/queue-consumer