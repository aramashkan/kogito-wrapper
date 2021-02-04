FROM azul/zulu-openjdk:11
VOLUME /tmp
RUN ./mvnw clean install -DskipTests
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]