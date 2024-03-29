#!/bin/bash

# 定义要遍历的文件夹列表
folders=(
  "fnnaug"
  "fnnconfig"
  "fnndataset"
  "fnnfunctor"
  "fnnmodel"
  "fnnmodule"
  # "fnnschedule"
  "fnnvisual"
)

# 遍历文件夹并执行pip install -e .
for folder in "${folders[@]}"; do
  cd "$folder" || exit
  pip install -e . -i https://pypi.tuna.tsinghua.edu.cn/simple
  cd ..
done
