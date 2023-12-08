# FNN Project

# Clone projects
``` bash
while read -r line; do git clone "$line"; done < submodules.txt
```

# Install projects
``` bash
./submodules_install.sh
```

# docker container setup

``` bash
# python debug
sudo chmod 777 /root -R

# install
./submodules_install.sh

# run train
python -m fnnschedule.tools.run train fnnconfig.movenet.movenet_pallet_12kp

```
