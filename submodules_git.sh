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
  echo -------- Processing $folder --------
  cd "$folder" || exit
  git $1
  cd ..
done
