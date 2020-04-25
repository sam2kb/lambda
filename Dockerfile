FROM amazonlinux AS build
WORKDIR /opt

ARG PYTHON_VER=3.8.2

# Install packages
# Need to set "ulimit -n" to a small value to stop yum from hanging:
# https://bugzilla.redhat.com/show_bug.cgi?id=1715254#c1
RUN ulimit -n 1024 && yum -y install \
    gcc \
    make \
    openssl-devel \
    bzip2-devel \
    libffi-devel \
    tar \
    gzip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install Python
RUN curl https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz -o python.tgz \
    && tar xzf python.tgz \
    && cd Python-$PYTHON_VER \
    && ./configure --enable-optimizations --prefix=/opt/python \
    && make -j install


FROM amazonlinux AS run
WORKDIR /opt

COPY --from=build /opt/python/. ./
COPY requirements.txt /requirements.txt

RUN ulimit -n 1024 && yum -y install \
    git \
    zip \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && /opt/bin/python3.8 -m pip install --upgrade pip \
    && /opt/bin/python3.8 -m pip install -r /requirements.txt