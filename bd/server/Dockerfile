FROM node:10-alpine

WORKDIR /log-server/bd/server/

COPY package* ./

RUN npm install

EXPOSE 5421

CMD npm start