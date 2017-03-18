FROM node:7.7

WORKDIR /app
ADD package.json .
RUN npm i

VOLUME /app

ENV NGINX_HOST=nginx
ADD . .
CMD [ "npm", "start" ]
