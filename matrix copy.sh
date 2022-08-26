buildargs="--build-arg BASE_IMAGE="
python_version=""
if [ -n "$python_version" ]; then
    buildargs+=" --build-arg PYTHON_VERSION=$python_version"
fi
echo "${buildargs}"