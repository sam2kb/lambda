#!/bin/bash

mkdir /deploy/python
cd /deploy/python

if [ ! -z "${GIT_REPO}" ]; then
    git clone ${GIT_REPO}
fi

if [ ! -z "${PIP_PACKAGES}" ]; then
    /opt/bin/python3.8 -m pip install ${PIP_PACKAGES} -t .
fi

# Untested optimization to reduce deployment size
# https://github.com/ralienpp/simplipy/blob/master/README.md
#python -m compileall -f .
#find . -name "*.py" -type f -delete
#find . -name "*.pyo" -type f -delete

# Remove test and dist-info directories
find . -name "test*" -type d -print0 | xargs -0 rm -rf
find . -name "*.dist-info" -type d -print0 | xargs -0 rm -rf

# Remove existing zips
rm -f ../lambda.zip
rm -f ../lambda-layer.zip

# Copy existing files from /src
cp -r /src/* ./

# Zip without the parent directory for use as lambda upload
zip -r ../lambda.zip * .[^.]*

cd ..

# Optionally remove the lambda handling file from the layer zip
if [ ! -z "${REM_LAMBDA_FILE}" ]; then
    rm -f python/${REM_LAMBDA_FILE}
fi

# Zip in a python directory for use as a lambda layer
zip -r lambda-layer.zip python

# Cleanup
rm -rf python