FROM amazonlinux:2 AS buildyum

WORKDIR /work

# Install git, SSH, and other utilities
ENV EPEL_REPO="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"

RUN set -ex \
    && yum install -y openssh-clients \
    && mkdir ~/.ssh \
    && touch ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H bitbucket.org >> ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts \
    && yum install -y $EPEL_REPO \
    && rpm --import https://download.mono-project.com/repo/xamarin.gpg \
    && curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo \
    && yum groupinstall -y "Development tools" \
    && yum install -y tar wget gzip glibc-langpack-ja GConf2 unzip python-configobj gcc curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker libsqlite3x-devel bzip2-devel readline-devel libffi-devel sudo xz-devel

# Set Lang JP
ENV LANG ja_JP.utf8
ENV LC_ALL ja_JP.utf8

RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/Japan /etc/localtime

# Install Git
RUN set -ex \
   && GIT_VERSION=2.26.2 \
   && GIT_TAR_FILE=git-$GIT_VERSION.tar.gz \
   && GIT_SRC=https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz  \
   && curl -L -o $GIT_TAR_FILE $GIT_SRC \
   && tar zxvf $GIT_TAR_FILE \
   && cd git-$GIT_VERSION \
   && make -j4 prefix=/usr \
   && make install prefix=/usr \
   && cd .. ; rm -rf git-$GIT_VERSION \
   && rm -rf $GIT_TAR_FILE /tmp/*

# Install NODEJS
ENV N_SRC_DIR="$SRC_DIR/n"
RUN git clone https://github.com/tj/n $N_SRC_DIR \
     && cd $N_SRC_DIR && make install
ENV NODE_10_VERSION="12.21.0"
RUN  n $NODE_10_VERSION && npm install --save-dev -g -f grunt && npm install --save-dev -g -f grunt-cli && npm install --save-dev -g -f webpack \
     && curl -sSL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
     && rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg \
     && yum install -y yarn \
     && yarn --version \
     && cd / && rm -rf $N_SRC_DIR; rm -rf /tmp/*

# Install puppeteer & chromium
RUN cd /tmp && \
    git clone --depth=1 https://github.com/alixaxel/chrome-aws-lambda.git && \
    cd chrome-aws-lambda && \
    make chrome_aws_lambda.zip && \
    cp chrome_aws_lambda.zip /opt && \
    cd /opt && \
    unzip chrome_aws_lambda.zip && \
    rm -f chrome_aws_lambda.zip

FROM lambci/lambda:nodejs12.x AS base

USER root 

WORKDIR /var/task  
COPY --from=buildyum /opt /opt  

CMD ["app.lambdaHandler"]