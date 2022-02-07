FROM alpine:latest

# copy files
COPY . /usr/src/
WORKDIR /usr/src/

# install packages
RUN cat packages.txt | xargs apk add --no-cache
