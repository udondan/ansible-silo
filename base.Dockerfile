# Copyright (c) 2017, Groupon, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FROM alpine:3.6

ENV container docker
ARG v
ENV SILO_BASE_VERSION ${v:-UNDEFINED}

ADD pip/pip.conf /etc/pip.conf

LABEL maintainer="Daniel Schroeder <daniel.schroeder@groupon.com>"

# Add testing repo, as we need this for installing gosu
RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories &&\

# Install curl
    apk add --no-cache openssl\
                       ca-certificates\
                       libssh2\
                       libcurl\
                       curl\

# Install bash
                       ncurses-terminfo-base\
                       ncurses-terminfo\
                       ncurses-libs\
                       readline\
                       bash\

# Install git
                       perl\
                       expat\
                       pcre\
                       git\

# Install python
                       libbz2\
                       libffi\
                       gdbm\
                       sqlite-libs\
                       py-netifaces\

# Install pip
                       py2-pip\

# Install Ansible dependencies
                       yaml\
                       gmp\

# Install gosu, which enables us to run Ansible as the user who started the container
                       gosu@testing\
                       sudo\

# Install ssh
                       openssh-client\
                       openssh-sftp-server\
                       openssh\
                       sshpass &&\

# Install some required python modules which need compiling
    apk add --no-cache gcc\
                       musl\
                       musl-dev\
                       musl-utils\
                       binutils-libs\
                       binutils\
                       isl\
                       libgomp\
                       libatomic\
                       pkgconf\
                       libgcc\
                       mpfr3\
                       mpc1\
                       libstdc++\
                       zlib-dev\
                       python2-dev\
                       openssl-dev\
                       libffi-dev\
                       libxml2-dev\
                       libxslt-dev &&\

    pip install asn1crypto==0.22.0\
                cffi==1.10.0\
                cryptography==2.0.2\
                enum34==1.1.6\
                idna==2.5\
                ipaddress==1.0.18\
                ncclient==0.5.3\
                paramiko==1.16.0\
                pycparser==2.18\
                pycrypto==2.6.1\
                six==1.10.0 &&\

    apk del --no-cache gcc\
                       python2-dev\
                       musl-dev\
                       binutils-libs\
                       binutils\
                       isl\
                       libgomp\
                       libatomic\
                       pkgconf\
                       libgcc\
                       mpfr3\
                       mpc1\
                       libstdc++\
                       zlib-dev\
                       python2-dev\
                       openssl-dev\
                       libffi-dev\
                       libxml2-dev\
                       libxslt-dev &&\

 # Install docker command and ensure it's always executed w/ sudo
    curl -fL -o /tmp/docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-17.06.0-ce.tgz" &&\
    tar -xf /tmp/docker.tgz --exclude docker/docker?* -C /tmp &&\
    mv /tmp/docker/docker /usr/local/bin/real-docker &&\
    rm -rf /tmp/docker /tmp/docker.tgz &&\
    echo "#!/usr/bin/env bash" > /usr/local/bin/docker &&\
    echo 'sudo /usr/local/bin/real-docker "$@"' >> /usr/local/bin/docker &&\
    chmod +x /usr/local/bin/docker &&\

# Show installed APK packages and their versions (to be copied into docs)
    apk info -v | sort | sed -E 's/-([0-9])/ \1/; s/^/- /' >&2
