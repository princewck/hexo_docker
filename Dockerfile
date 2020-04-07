FROM mhart/alpine-node

LABEL author="princewck"

ADD . /app

WORKDIR /app

EXPOSE 4000/tcp

RUN npm install -g cnpm --registry="https://registry.npm.taobao.org"
RUN ["cnpm", "install"]
ENTRYPOINT ["npm", "run", "deploy"]