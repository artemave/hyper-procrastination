FROM node:7.7

WORKDIR /app
ADD package.json .
RUN npm i

VOLUME ./results

ENV NGINX_HOST=nginx
ADD . .
CMD [ "npm", "start" ]
