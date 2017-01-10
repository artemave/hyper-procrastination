FROM node

WORKDIR /app
ADD package.json .
RUN npm i

ENV NGINX_HOST=nginx
ADD . .
CMD [ "npm", "start" ]
