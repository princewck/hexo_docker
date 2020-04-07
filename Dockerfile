FROM node:10

LABEL author="princewck"

ADD . /app

WORKDIR /app

EXPOSE 4000/tcp

RUN ["yarn", "install"]
ENTRYPOINT ["npm", "run", "deploy"]