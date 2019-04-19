PID=`cat .pid`
echo ${PID}
docker stop ${PID}