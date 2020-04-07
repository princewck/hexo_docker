FROM node:10

LABEL author="princewck"

ADD . /app

WORKDIR /app

EXPOSE 4000/tcp

RUN yarn add -g node-sass --no-progress
RUN npm install -g yarn
RUN ["yarn", "install"]
ENTRYPOINT ["npm", "run", "deploy"]