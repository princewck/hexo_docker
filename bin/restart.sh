#!env /bin/bash
PID=`cat .pid`
docker build --no-cache -t hexo_docker .
echo "构建成功，停止旧服务${PID}"
docker stop ${PID}
docker run -p 4001:4000 -d hexo_docker > .pid
