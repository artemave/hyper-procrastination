FROM node

WORKDIR /app
ADD package.json .
RUN npm i

ADD . .
CMD [ "npm", "start" ]
