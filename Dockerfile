FROM arm64v8/alpine:latest
# FROM alpine:latest

# install docker client
RUN apk update \
    && apk upgrade \
    && apk add vlc \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["cvlc"]
CMD ["--version"]