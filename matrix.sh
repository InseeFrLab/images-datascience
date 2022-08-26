#!/usr/bin/bash
base_image=image1,image2
python_version=v1,v2
context=python

result=""
if [[ "$context" =~ ^(base)$ ]]; then
    echo "$context is in the list"
    IFS=', ' read -r -a array <<< "$base_image"
    for element in "${array[@]}"
    do
        JSON_STRING=$( jq -n \
                  --arg bn "$element" \
                  '{base_image: $bn}' )
        echo $JSON_STRING
        result+=("$JSON_STRING")
    done
fi

if [[ "$context" =~ ^(python)$ ]]; then
    echo "$context is in the list"
    IFS=', ' read -r -a array <<< "$base_image"
    IFS=', ' read -r -a python_version_array <<< "$python_version"
    for element in "${array[@]}"
    do
      for pv in "${python_version_array[@]}"
      do
        JSON_STRING=$( jq -n \
                  --arg bn "$element" \
                  --arg pv "$pv" \
                  '{base_image: $bn, python_version_array: $pv}' )
        echo $JSON_STRING
        result+="$JSON_STRING,"
      done
    done
fi

r=${result::-1}
echo "{"inputs":[$r]