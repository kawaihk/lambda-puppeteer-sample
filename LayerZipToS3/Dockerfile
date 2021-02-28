#Set Docker Image
FROM  XXXXXXXX AS lambda 

USER root 

FROM amazonlinux:2 AS backup

WORKDIR /work

ENV EPEL_REPO="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"

# Install git, SSH, and other utilities
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

#AWS CLI V2
RUN set -ex \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm -rf ./aws ./awscliv2.zip

COPY --from=lambda /opt /opt  

# docker build --no-cache --tag YYYYYYY .
# docker run --privileged -d -v $HOME/.aws:/root/.aws YYYYYYY
# docker ps -a
# docker exec -it ZZZZZZZZ bash
# cd /opt
# zip -r nodejs_puppeteer_layer.zip .
# aws s3 cp nodejs_puppeteer_layer.zip s3://mybucket/path/to/
CMD ["/sbin/init"]
