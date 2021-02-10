FROM maven:3.6.3-jdk-11 AS build
RUN mkdir /kogito
COPY . /kogito
RUN ls /kogito
RUN mvn -f /kogito/pom.xml clean install -DskipTests


FROM azul/zulu-openjdk:11
COPY --from=build /kogito/target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
