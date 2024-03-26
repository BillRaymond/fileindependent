FROM ubuntu:23.10
RUN echo "#################################################"
RUN echo "Set the timezone and suppress manual inputs"
RUN echo "(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)"
ARG TIMEZONE="US/Pacific"
ARG DEBFRONTEND="noninteractive"
ENV TZ=$TIMEZONE \
    DEBIAN_FRONTEND=$DEBFRONTEND

RUN echo "#################################################"
RUN echo "Get the latest APT packages"
RUN echo "apt-get update"
RUN apt update && \
    apt-get -y update

RUN echo "#################################################"
RUN echo "Install pre-requisites and some preferential tools"
RUN apt-get -y install --no-install-recommends \
    wget \
    curl \
    build-essential \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev \
    apt-utils \
    jq \
    ca-certificates \
    tar \
    xz-utils

RUN echo "#################################################"
RUN echo "Install Node.js, npm, and Dart SASS with specific versions to ensure compatibility"
ARG NODE_VERSION=20.x
ENV NPM_VERSION=10.5.0
ENV SASS_VERSION=1.72.0

RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g npm@$NPM_VERSION sass@$SASS_VERSION

RUN echo "#################################################"
RUN echo "Install go and Hugo"
RUN apt-get install -y \
        golang-go \
        hugo

RUN echo "#################################################"
RUN echo "Install a specific version of Go (golang) for the current architetcure"
ARG GO_VERSION=1.22.1
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
RUN apt-get update && \
    apt-get install -y curl git build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -L "https://golang.org/dl/go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz" | tar -C /usr/local -xz

RUN echo "#################################################"
RUN echo "Install a specific version of Hugo for the current architetcure"
ARG HUGO_VERSION=0.124.1
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) HUGO_ARCH="64bit" ;; \
        aarch64) HUGO_ARCH="arm64" ;; \
        arm*) HUGO_ARCH="arm" ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    HUGO_DOWNLOAD="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-${HUGO_ARCH}.tar.gz" && \
    curl -Ls $HUGO_DOWNLOAD | tar -xz -C /usr/local/bin hugo

RUN echo "#################################################"
RUN echo "Clean things up"
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

