FROM maven:3.6.3-jdk-11 AS build
RUN mkdir /kogito-wrapper
WORKDIR /kogito-wrapper
COPY . /kogito-wrapper
RUN ls -la /kogito-wrapper
RUN mvn -f /kogito-wrapper/pom.xml clean install -DskipTests

FROM azul/zulu-openjdk:11
COPY --from=build /kogito-wrapper/target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
