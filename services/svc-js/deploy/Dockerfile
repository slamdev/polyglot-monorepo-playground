FROM node:10-alpine

COPY build /opt/app

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "node /opt/app/index.js"]
