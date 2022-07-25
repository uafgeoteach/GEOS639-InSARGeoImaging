#!/usr/bin/env bash

set -ex

python -m pip install --user \
    ipywidgets \
    mpldatacursor

python=$(python --version 2>&1)
v=$(echo $python | cut -d'.' -f 2)

# Add Path to local pip execs.
export PATH=$HOME/.local/bin:$PATH

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

echo "$PREFIX"
if [ ! -d "$PREFIX" ]; then
  echo "mamba create"
  mamba env create -f "$ENVS"/"$NAME".yml -q

  mamba run -n "$NAME" kernda --display-name "$NAME" -o --env-dir "$PREFIX" "$PREFIX"/share/jupyter/kernels/python3/kernel.json
  source ${GEO_FILE}/unavco.sh
else
  echo "mamba update"
  mamba env update -f "$ENVS"/"$NAME".yml -q
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

if [ ! -f "$HOME/.jupyter/jupyter_lab_config.py" ]; then
cat <<EOT > "$HOME"/.jupyter/jupyter_lab_config.py
c.InteractiveShellApp.extensions = ['df_jupyter_magic']
c.NotebookApp.kernel_manager_class = ['notebook.services.kernels.kernelmanager.AsyncMappingKernelManager']
EOT
fi