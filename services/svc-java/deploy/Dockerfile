FROM openjdk:8-jre-alpine

COPY build/libs /opt/app

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java -cp /opt/app/svc-java.jar Server"]
