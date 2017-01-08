FROM node

WORKDIR /app
ADD package.json .
RUN npm i

ADD . .
ENV DEBUG=test
CMD [ "npm", "start" ]
