FROM ubuntu:22.04

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    make \
    git \
    gperf \
    wget \
    perl \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Homebrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.bashrc

# Install Homebrew dependencies
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && brew install gperf cmake openssl@3

# Build telegram-bot-api
ARG TELEGRAM_API_REF=master
ARG ARCH=arm64
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
    && git clone --recursive https://github.com/tdlib/telegram-bot-api.git /telegram-bot-api \
    && cd /telegram-bot-api \
    && git checkout ${TELEGRAM_API_REF} \
    && rm -rf build \
    && mkdir build \
    && cd build \
    && OPENSSL_DIR="/home/linuxbrew/.linuxbrew/opt/openssl@3" \
    && BINARY_NAME="telegram-bot-api-${ARCH}" \
    && cmake -DCMAKE_BUILD_TYPE=Release -DOPENSSL_ROOT_DIR=$OPENSSL_DIR -DCMAKE_INSTALL_PREFIX:PATH=.. .. \
    && cmake --build . --target install \
    && cd ../.. \
    && mv telegram-bot-api/bin/telegram-bot-api telegram-bot-api/bin/$BINARY_NAME \
    && ls -l telegram-bot-api/bin/$BINARY_NAME \
    && file telegram-bot-api/bin/$BINARY_NAME