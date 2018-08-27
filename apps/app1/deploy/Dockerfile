FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY build /usr/share/nginx/html

EXPOSE 80
