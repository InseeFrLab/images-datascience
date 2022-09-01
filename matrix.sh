#!/bin/bash
FILES="./releases/*"
for f in $FILES
do
	echo "Processing $f"
    jq '.[] | .artefact_output_name' $f
done