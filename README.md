# Build Python AWS Lambda deployment packages with Docker

We are building for Python 3.8 and on the latest `amazonlinux 2`. You can either use `lambda.zip` directly or add `lambda-layer.zip` as a layer to your `lambda_function.py`. Python binary is in `/opt/bin/python3.8`.

## Why?

* Logging in to EC2 and [creating a deployment package by hand](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html) is clumsy. Instead, script package creation around the [`amazonlinux 2` image](https://hub.docker.com/_/amazonlinux/).

## How to use

* Mount `/src` as a docker volume, this is where you should put your lambda code.
* Deployment packages `lambda.zip` and `lambda-layer.zip` are written to `/deploy` directory.
* Modify and mount `run.sh` script to `/opt/run.sh`.
* Pass environment variables:
    * `GIT_REPO` - clone this git repo into `/src`.
    * `PIP_PACKAGES` - space separated list of packages you want to add to your lambda zip.
    * `REM_LAMBDA_FILE` - (OPTIONAL) remove the original `lambda_function.py` file from `lambda-layer.zip` if you don't need it there.

```sh
$ docker pull sam2kb/lambda

$ docker run --rm \
  -v "$(pwd)/src:/src" \
  -v "$(pwd)/run.sh:/opt/run.sh" \
  -v "$(pwd)/deploy:/deploy" \
  -e GIT_REPO="https://github.com/some/repo" \
  -e PIP_PACKAGES="cryptography imap_tools " \
  -e REM_LAMBDA_FILE="lambda_function.py" \
  sam2kb/lambda \
  bash /opt/run.sh
```

## Or run with docker-compose
Remember to modify `docker-compose.yml` file first

```sh
$ docker-compose run --rm lambda

```

## Customize
Modify `run.sh` to suit your own purposes

## Use another Python version

Pass a build ARG with any other Python version as such `PYTHON_VER=3.8.0`

```sh
$ docker build --build-arg PYTHON_VER=3.8.0 -t mylambda .
```

Or with `docker-compose`

```sh
$ docker-compose build --build-arg PYTHON_VER=3.8.0
```