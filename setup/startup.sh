#!/usr/bin/env bash

set -ex

# python -m pip install --user \
#     nbgitpuller \
#     ipywidgets \
#     mpldatacursor

python -m pip install --user \
    ipywidgets \
    mpldatacursor

# # copy over our version of pull.py
# # REMINDER: REMOVE IF CHANGES ARE MERGED TO NBGITPULLER
python=$(python --version 2>&1)
v=$(echo $python | cut -d'.' -f 2)
# cp "${GEO_FILE}"/pull.py /home/jovyan/.local/lib/python3."$v"/site-packages/nbgitpuller/pull.py

# # enable nbgitpuller
# jupyter serverextension enable --py nbgitpuller

# Add Path to local pip execs.
export PATH=$HOME/.local/bin:$PATH

# # Pull in any repos you would like cloned to user volumes
# gitpuller https://github.com/uafgeoteach/GEOS639-InSARGeoImaging.git main $HOME/GEOS639

CONDARC=$HOME/.condarc
if ! test -f "$CONDARC"; then
cat <<EOT >> $CONDARC
channels:
  - conda-forge
  - defaults
channel_priority: strict
envs_dirs:
  - /home/jovyan/.local/envs
  - /opt/conda/envs
EOT
fi

conda init

# added unavco
echo "create directory"
mkdir -p "$HOME"/.local/envs/

############### Copy to .local/envs ###############
LOCAL="$HOME"/.local
ENVS="$LOCAL"/envs
NAME=unavco
PREFIX="$ENVS"/"$NAME" 
SITE_PACKAGES=$PREFIX"/lib/python3."$v"/site-packages"
##############################################################

# PREFIX = /home/jovyan/.local/envs/unavco
# ENVS/NAME = /home/jovyan/.local/envs/unavco.yml -> not found

# YML location: $HOME/setup/unavco

echo "$PREFIX"
if [ ! -d "$PREFIX" ]; then
  echo "mamba create"
  mamba env create -f "$ENVS"/"$NAME".yml -q
  # mamba env create -f "$HOME"/setup/"$NAME".yml -q

  mamba run -n "$NAME" kernda --display-name "$NAME" -o --env-dir "$PREFIX" "$PREFIX"/share/jupyter/kernels/python3/kernel.json
  # mamba run -n "$NAME" kernda --display-name "$NAME" -o --env-dir "$PREFIX" "$PREFIX"/share/jupyter/kernels/python3/kernel.json
  source ${GEO_FILE}/unavco.sh
else
  echo "mamba update"
  mamba env update -f "$ENVS"/"$NAME".yml -q
  # mamba env update -f "$HOME"/setup/"$NAME".yml -q
fi

################ back to startup.sh original ################### 

echo "mamba clean"

mamba clean --yes --all

# check if config file exists
JN_CONFIG=$HOME/.jupyter/jupyter_notebook_config.json

# generate config file if it doesn't exist
if [ ! -f "$HOME/.jupyter" ]; then
  echo "Creating jupyter_notebook_config.json"
  mkdir -p "$HOME/.jupyter"
  touch "$JN_CONFIG"
fi

if ! grep -q "\"CondaKernelSpecManager\":" "$JN_CONFIG"; then
jq '. += {"CondaKernelSpecManager": {"name_format": "{display_name}", "env_filter": ".*opt/conda.*"}}' "$JN_CONFIG" >> temp;
mv temp "$JN_CONFIG";
fi

BASH_RC=/home/jovyan/.bashrc
grep -qxF 'conda activate unavco' $BASH_RC || echo 'conda activate unavco' >> $BASH_RC

# bash profile has dup in unavco.sh
BASH_PROFILE=$HOME/.bash_profile
if ! test -f "$BASH_PROFILE"; then
cat <<EOT > $BASH_PROFILE
if [ -s ~/.bashrc ]; then
    source ~/.bashrc;
fi
EOT
fi

python -m pip install df-jupyter-magic


# DF="c.InteractiveShellApp.extensions = ['df_jupyter_magic']"
# KRNL="c.NotebookApp.kernel_manager_class = ['notebook.services.kernels.kernelmanager.AsyncMappingKernelManager']"
# LAB_CONFIG='.jupyter/jupyter_lab_config.py'
# grep -qF -- "$DF" "$LAB_CONFIG" || echo "$DF" >> "$LAB_CONFIG"
# grep -qF -- "$KRNL" "$LAB_CONFIG" || echo "$KRNL" >> "$LAB_CONFIG"

# $lab_con=$(pwd)/.jupyter/jupyter_lab_config.py
# grep -qxF "c.InteractiveShellApp.extensions = ['df_jupyter_magic']" $lab_con ||\
#   echo "c.InteractiveShellApp.extensions = ['df_jupyter_magic']" >> $lab_con

# grep -qxF "c.NotebookApp.kernel_manager_class = ['notebook.services.kernels.kernelmanager.AsyncMappingKernelManager']" $lab_con ||\
#   echo "c.NotebookApp.kernel_manager_class = ['notebook.services.kernels.kernelmanager.AsyncMappingKernelManager']" >> $lab_con

############################### PREV CODE DOWN ######################################

if [ ! -f "$HOME/.jupyter/jupyter_lab_config.py" ]; then
cat <<EOT > "$HOME"/.jupyter/jupyter_lab_config.py
c.InteractiveShellApp.extensions = ['df_jupyter_magic']
c.NotebookApp.kernel_manager_class = ['notebook.services.kernels.kernelmanager.AsyncMappingKernelManager']
EOT
fi


# if [ ! -f "$HOME/.ipython/profile_default/ipython_config.py" ]; then
# cat <<EOT > "$HOME"/.ipython/profile_default/ipython_config.py
# c.InteractiveShellApp.extensions = ['df_jupyter_magic']
# EOT
# fi
