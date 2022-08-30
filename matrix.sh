#!/usr/bin/bash
base_image=image1,image2
python_version=v1,v2
context=python
a=ubuntu:20.04
b=nvidia/cuda:11.3.1-base-ubuntu20.04

base_image_escaped=$(echo $a  | sed 's/\//\\\//g' )
echo $base_image_escaped
base_image_gpu_escaped=$(echo $b | sed 's/\//\\\//g' )
echo $base_image_gpu_escaped
sed -i "s/:base_image_gpu/$base_image_gpu_escaped/g" ./releases/base.json
sed -i "s/:base_image/$base_image_escaped/g" ./releases/base.json
matrix=$(cat ./releases/base.json | jq .) 
echo $matrix   