#
# Build stage
#
FROM openjdk:11.0-jdk-slim AS build
COPY src /home/app/src
COPY .mvn /home/app/.mvn
COPY pom.xml /home/app
COPY mvnw /home/app
WORKDIR /home/app
RUN --mount=type=cache,target=/root/.m2 ./mvnw package

#
# Package stage
#
FROM openjdk:11.0-jre-slim
COPY --from=build /home/app/target/spring-petclinic-2.7.3.jar /usr/local/lib/spring-petclinic.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/spring-petclinic.jar"]
