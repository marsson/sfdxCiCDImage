FROM alpine:latest

RUN apk add --update --no-cache git openssh ca-certificates openssl
RUN apk add --no-cache bash
RUN apk add --no-cache curl vim
RUN apk add --update nodejs nodejs-npm

# install latest sfdx from npm
RUN npm install sfdx-cli --global
RUN sfdx --version
RUN sfdx plugins --core