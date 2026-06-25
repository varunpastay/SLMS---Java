FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jre17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/slms.war /usr/local/tomcat/webapps/ROOT.war
RUN mkdir -p /opt/slms_uploads
EXPOSE 8080
CMD ["catalina.sh", "run"]
