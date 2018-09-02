FROM openjdk:8-jre-alpine

COPY build/libs /opt/app

EXPOSE 8080

ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=1"

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -cp /opt/app/svc-java.jar Server"]
