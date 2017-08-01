FROM node:8.1

WORKDIR /app
ADD package.json .
RUN npm i

VOLUME ./results

ENV NGINX_HOST=nginx
ADD . .
CMD [ "node", "getAndParseBigJson.js" ]
