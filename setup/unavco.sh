#!/bin/bash

set -e

# Assume gitpuller already installed

PATH=$HOME/.local/bin:$PATH

LOCAL="$HOME"/.local
NAME=unavco
SITE_PACKAGES="$LOCAL/envs/$NAME/lib/python3.8/site-packages"

pythonpath="$PYTHONPATH"
path="$PATH"

####### Set ISCE env vars ########
pythonpath="$SITE_PACKAGES/isce:$pythonpath"
path="$SITE_PACKAGES/isce/applications:$LOCAL/envs/$NAME/bin:$path"
conda env config vars set -n $NAME ISCE_HOME="$SITE_PACKAGES"/isce

####### Install ARIA-Tools ########

# clone the ARIA-Tools repo and build ARIA-Tools
aria="$LOCAL/ARIA-tools"
if [ ! -d "$aria" ]
then
    git clone -b release-v1.1.2 https://github.com/aria-tools/ARIA-tools.git "$aria"
    wd=$(pwd)
    cd "$aria"
    conda run -n $NAME python "$aria"/setup.py build
    conda run -n $NAME python "$aria"/setup.py install
    cd "$wd"
fi

conda env config vars set -n $NAME GDAL_HTTP_COOKIEFILE=/tmp/cookies.txt
conda env config vars set -n $NAME GDAL_HTTP_COOKIEJAR=/tmp/cookies.txt
conda env config vars set -n $NAME VSI_CACHE=YES

# clone the ARIA-tools-docs repo
aria_docs="$LOCAL/ARIA-tools-docs"
if [ ! -d $aria_docs ]
then
    git clone -b master --depth=1 --single-branch https://github.com/aria-tools/ARIA-tools-docs.git $aria_docs
fi

# set PATH and PYTHONPATH
conda env config vars set -n $NAME PATH="$path"
conda env config vars set -n $NAME PYTHONPATH="$pythonpath"