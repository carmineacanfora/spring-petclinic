#
# Build stage
#
FROM openjdk:18.0.2.1-jdk-slim-bullseye AS build
COPY src /home/app/src
COPY .mvn /home/app/.mvn
COPY pom.xml /home/app
COPY mvnw /home/app
WORKDIR /home/app
RUN --mount=type=cache,target=/root/.m2 ./mvnw package

#
# Package stage
#
FROM openjdk:18.0.2.1-slim-bullseye
COPY --from=build /home/app/target/spring-petclinic-2.7.3.jar /usr/local/lib/spring-petclinic.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/spring-petclinic.jar"]
