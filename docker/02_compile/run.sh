cd /workspaces

source /opt/vitis_ai/conda/etc/profile.d/conda.sh
conda activate vitis-ai-pytorch

# 编译模型
MODEL_NAME=fnn_model

vai_c_xir -x /FNNQuantedModel_int.xmodel  -a /arch.json -o /output -n $MODEL_NAME
xir subgraph /output/$MODEL_NAME.xmodel | grep DPU

rm -rf /upload/*
cp /output/$MODEL_NAME.xmodel /upload/$MODEL_NAME.xmodel
