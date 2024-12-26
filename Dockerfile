FROM arm64v8/alpine:latest
# FROM alpine:latest

ENV VLC_UID=1000
ENV AUDIO_GID=29

ENV HOME="/vlc"

# install docker client
RUN apk update \
    && apk upgrade \
    && apk add vlc \
    && apk add shadow \
    && groupmod -g ${AUDIO_GID} audio \
    && adduser -h ${HOME} -s /bin/sh -D -u ${VLC_UID} -G audio vlc \
    && apk add alsa-utils \
    && rm -rf /var/cache/apk/*

USER vlc
WORKDIR "/vlc"

ENTRYPOINT ["cvlc"]
CMD ["--version"]