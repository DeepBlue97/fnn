####################################
#  How to build docker image
# Method Ⅰ (recommended): open in vscode dev-containor, and setup the enviroment, then use "docker commit xxxxx xilinx/yolox-train:v1.0.0"
# Method Ⅱ: use this Dockerfile to build.
####################################

FROM xilinx/vitis-ai-pytorch-gpu-yolox:3.0.0.006

USER vitis-ai-user

RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user imgaug -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user opencv-python -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user albumentations -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user pycocotools -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user paho-mqtt -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user tabulate -i https://pypi.tuna.tsinghua.edu.cn/simple

USER root
RUN useradd -u 1001 mitan 
RUN usermod -aG mitan vitis-ai-user
RUN newgrp mitan

#  \
#     && useradd -u 1001 -g mitan -s /bin/bash -m mitan

# RUN usermod -aG mitan \
#     && newgrp mitan

# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip list | grep imgaug
# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip list | grep pycocotools
# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip list
# # conda activate vitis-ai-pytorch
# # conda activate vitis-ai-optimizer_pytorch

# WORKDIR /tmp
# COPY code/requirements.txt .
# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user numpy==1.17.2 -i https://pypi.tuna.tsinghua.edu.cn/simple
# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user scipy==1.3.1 -i https://pypi.tuna.tsinghua.edu.cn/simple

# WORKDIR /workspace
# COPY * .
# # RUN ls -l /workspace

# # WORKDIR /workspaces/code
# # RUN echo ${ls}
# RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user -v -e . -i https://pypi.tuna.tsinghua.edu.cn/simple

# # sudo chmod 777 /root -R
# # conda activate vitis-ai-pytorch # default
# # for install yolox
# # WORKDIR /workspace/code
# # RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user -v -e . -i https://pypi.tuna.tsinghua.edu.cn/simple

# # cd /
# # RUN /opt/vitis_ai/conda/envs/vitis-ai-pytorch/bin/pip install --user sklearn -i https://pypi.tuna.tsinghua.edu.cn/simple

# # # install lib
# # RUN apt-get update
# # RUN apt install libgl1-mesa-glx libglib2.0-dev -y

# # 升级pip并换源
# RUN python -m pip install -i https://pypi.douban.com/simple --upgrade pip

# RUN pip config set global.index-url https://pypi.douban.com/simple

# # 切换到临时目录放置requirements.txt，并pip安装依赖
# WORKDIR /tmp
# COPY code/requirements.txt .
# RUN pip install -r requirements.txt

# # 国内源更新不及时，单独安装ultralytics
# RUN pip install ultralytics==8.0.112 -i https://pypi.org/simple

# RUN conda install git -y

# RUN apt install wget -y
# # RUN wget https://ultralytics.com/assets/Arial.ttf /root/.config/Ultralytics/Arial.ttf

# COPY code/Arial.ttf /root/.config/Ultralytics/Arial.ttf

# # # 提前下载的公开预训练模型拷贝
# # WORKDIR /tmp
# # # RUN echo ${ls}
# # COPY pretrained_model/ .


# # RUN wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt

# # COPY requirements.txt /tmp/

# # # 切换到 /app 目录
# # WORKDIR /tmp

# # # 安装依赖包
# # RUN pip install -r requirements.txt


# # COPY requirements.txt /tmp/requirements.txt
# # # RUN ["pip", "install", "-r", "/tmp/requirements.txt"]
# # # RUN pip install -r requirements.txt
# # RUN pip install -r /tmp/requirements.txt
 
# # RUN pip install -U pip
# # RUN pip install terminaltables==3.1.10
# # RUN pip install imgaug==0.4.0
# # # RUN conda install imgaug -y
# # RUN pip install pillow==8.3.2
# # RUN pip install scipy==1.8
# # RUN pip install scikit-image==0.18.0
# # RUN pip install tensorboard==2.13.0
# # RUN pip install pycocotools==2.0.6
