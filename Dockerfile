FROM alpine:3.21.3
RUN apk update && apk add --no-cache \
  bash \
  fish \
  zsh \
  eza \
  curl \
  git \
  gcc \
  vim \
  nano \
  micro \
  tar \
  zip \
  unzip \
  nmap \
  net-tools \
  netcat-openbsd \
  openssl \
  musl-dev \
  binutils-gold \
  g++ \
  gnupg \
  libgcc \
  linux-headers \
  make \
  python3 \
  py-setuptools \
  ca-certificates
WORKDIR /root
COPY setup.fish .
RUN chmod +x setup.fish && ./setup.fish
COPY .npmrc /root/.local/share/nvm/v23.9.0/etc
RUN mkdir -p /app
WORKDIR /app
CMD ["fish", "start.fish"]
