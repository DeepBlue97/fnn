docker run --rm -it --shm-size=32G -v /opt/mitan/fnn/:/workspaces -v /opt/mitan/datasets/:/datasets  --device=/dev/kfd --device=/dev/dri/  56c3d07e8e02

docker run --rm -it --shm-size=32G -v /opt/mitan/fnn/:/workspaces -v /opt/mitan/datasets/:/datasets  --device=/dev/kfd --device=/dev/dri/  mitan/fnn-pytorch-dcu-yolox:0.0.2
