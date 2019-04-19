#!env /bin/bash
docker build --no-cache -t hexo_docker .
docker run -p 4001:4000 -d hexo_docker > .pid