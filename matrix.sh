#!/bin/bash
FILES="./releases/*"
data=[]
for f in $FILES
do
	echo "Processing $f"
    array=$(jq '.[] | .artefact_output_name' $f)
    for a in ${array[@]}; do
        echo "$a"
        data=$(echo $data | jq ". += [{"image":$a}]")
    done
done
echo $data