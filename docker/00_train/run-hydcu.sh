cd /workspaces

# install fnn submodules
./submodules_install.sh

# link soft
ln -sf /config.py /workspaces/fnnconfig/src/fnnconfig/config__.py

python -m fnnmodel.tools.run train fnnconfig.config__
