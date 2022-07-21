#!/bin/bash

set -ex

docker build -f setup/dockerfile -t geos639:latest .

docker volume create geo_vol

# op1
## partially works
docker run -it -d -v geo_vol:/home/jovyan/ --rm --name copycon busybox:latest
docker cp $(pwd) copycon:$HOME/
docker stop copycon
# docker run --name geocon -p 8888:8888 -v geo_vol:/home/jovyan jupyter/base-notebook:python-3.9.2 
docker run --name geocon -p 8888:8888 -v geo_vol:/home/jovyan geos639
startup.sh

# op2

#docker run -dit --name jcon -v geo_vol:/home/jovyan jupyter/base-notebook:python-3.9.2
#docker cp $(pwd) jcon:/home/jovyan
#docker exec jcon startup.sh

# docker run -it --name geos639 --rm -p 8888:8888 -v $(pwd):/home/jovyan geos639:latest
