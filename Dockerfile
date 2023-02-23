#use  docker run --interactive --tty sfdxcialpine to bash into the image for testing
#docker run -it -e SFDX_VERSION=7.177.0 sfdxcialpine

FROM alpine:latest


RUN apk add --update --no-cache git openssh ca-certificates openssl
RUN apk add --no-cache bash
RUN apk add --no-cache curl vim
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main/" >> /etc/apk/repositories \
    && apk add --update nodejs npm jq
# install latest sfdx from npm

RUN npm install sfdx-cli${SFDX_VERSION} --global
RUN echo
RUN sfdx plugins:install @salesforce/sfdx-scanner
RUN sfdx plugins:install sfdmu
RUN echo y | sfdx plugins:install sfdx-git-delta
RUN mkdir -p /var/salesforce
