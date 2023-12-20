####################################
#  How to build docker image
# Method Ⅰ (recommended): open in vscode dev-containor, and setup the enviroment, then use "docker commit xxxxx xilinx/yolox-train:v1.0.0"
# Method Ⅱ: use this Dockerfile to build.
####################################

# FROM xilinx/vitis-ai-pytorch-gpu-yolox:3.0.0.005
FROM mitan/fnn-pytorch-dcu-yolox:0.0.1

RUN pip install imgaug -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install pycocotools -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install albumentations -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install opencv-python -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install loguru -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install paho-mqtt -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install tabulate -i https://pypi.tuna.tsinghua.edu.cn/simple
