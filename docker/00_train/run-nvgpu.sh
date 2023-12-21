cd /workspaces

# access to conda env for viti-ai container
source /opt/vitis_ai/conda/bin/activate vitis-ai-pytorch

# install fnn submodules
./submodules_install.sh

# link soft
ln -sf /config.py /workspaces/fnnconfig/src/fnnconfig/config__.py

python -m fnnmodel.tools.run train fnnconfig.config__
