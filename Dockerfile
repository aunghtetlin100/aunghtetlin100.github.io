# Specify the base image for the build stage
FROM maven:3.6.0-jdk-11-slim AS build
ENV BASE_DIR="/home/demo"
ENV SERVICE_NAME="spring-boot-jpa-postgresql-github"

# Set the working directory for the build stage
WORKDIR $BASE_DIR/$SERVICE_NAME

# Copy the source code and dependencies
COPY src src
COPY pom.xml .

# Build the application
RUN mvn clean package -DskipTests

# Specify the base image for the package stage
FROM eclipse-temurin:11.0.19_7-jre-alpine
ENV BASE_DIR="/home/demo"
ENV SERVICE_NAME="spring-boot-jpa-postgresql-github"
ENV JVM_OPTS="-XX:MaxRAMPercentage=80.0"
ENV TIME_ZONE="Asia/Yangon"

# Copy artifacts from the build stage
COPY --from=build $BASE_DIR/$SERVICE_NAME/target/$SERVICE_NAME.jar ./lib/$SERVICE_NAME.jar
COPY --from=build $BASE_DIR/$SERVICE_NAME/src/main/resources/config.xml ./conf/config.xml

# Install timezone data
RUN apk add --no-cache tzdata
RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone

# Define the entry point to start the application
ENTRYPOINT exec java $JVM_OPTS -jar -Xbootclasspath/a:./conf ./lib/$SERVICE_NAME.jar