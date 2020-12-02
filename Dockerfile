# An Alpine image with curl, jq and yq installed to be used in a CI environment to fetch
# and convert into yaml files the payloads from Vault API
FROM alpine:3.7
RUN apk add --no-cache \
    curl \
    jq \
    wget \
    bash

# install yq YAML processor to convert json payload from Vault API
RUN wget https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq