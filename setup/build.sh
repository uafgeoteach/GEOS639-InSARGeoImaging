#!/bin/bash

set -ex

docker build -f setup/dockerfile -t geos639:latest .

docker run -it --name geos639 --rm -p 8888:8888 -v $(pwd):/home/jovyan geos639:latest