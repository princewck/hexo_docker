FROM mhart/alpine-node

LABEL author="princewck"

ADD . /app

WORKDIR /app

EXPOSE 4000/tcp

RUN ["npm", "install", "--registry", "https://registry.npm.taobao.org"]
ENTRYPOINT ["npx", "hexo", "server"]