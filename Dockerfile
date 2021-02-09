FROM maven:3.6.3-jdk-8-slim AS build
RUN mvn clean install -DskipTests

FROM azul/zulu-openjdk:11
COPY --from=build target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
