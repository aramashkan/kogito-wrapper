FROM maven:3.6.3-jdk-11 AS build
RUN mkdir /kogito
COPY . /kogito
RUN ls /kogito
RUN mvn -f /kogito/pom.xml clean install -DskipTests


FROM azul/zulu-openjdk:11
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
COPY --from=build /kogito/target/*.jar app.jar
EXPOSE 8181
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
