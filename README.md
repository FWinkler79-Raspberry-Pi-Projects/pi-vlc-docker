# pi-vlc-docker

A VLC docker image for Raspberry-Pi to play back audio and use as an Audio output channel in HomeAssistant.

- [What is Pi-VLC-Docker?](#what-is-pi-vlc-docker)
- [How it works](#how-it-works)
- [Building](#building)
- [Dockerfile](#dockerfile)
  - [❗Mapping `audio` Group Inside the Docker Container](#mapping-audio-group-inside-the-docker-container)

## What is Pi-VLC-Docker?

Pi-VLC-Docker is a docker image for Raspberry-Pi that contains VLC media player. It can be used to play back audio from Home Assistant via the VLC-Telnet plugin. The image is built from an Alpine Linux base image and only includes the most necessary dependencies. That makes it relatively lightweight.

Though this image is currently using a "headless" VLC, it could also be extended to stream or play back video even on the Raspberry-Pi itself.
This might come in handy when directly connecting the Raspberry-Pi to a screen or TV and using it as a video playback device.

You can find this image published on Docker hub: [fwinkler79/arm64v8-vlc-docker:1.0.0](https://hub.docker.com/r/fwinkler79/arm64v8-vlc-docker/tags)

## How it works

The docker image contains VLC and is configured to start the `cvlc` command - a headless (i.e. UI-less) version of VLC.

This can for example be used in a `docker-compose.yaml`, to start VLC with the `telnet` interface active (running on a specific port and using a specific telnet password). This interface (i.e. port and password) could then be configured in Home Assistant's `vlc-telnet` add on, so that Home Assistant can use it as a playback device.

Many other use cases are possible, however.

## Building

To build the image use the `build.sh` script and execute it in the folder where the `Dockerfile` resides by executing:

```shell
./build.sh
```

This executes a Docker cross-platform build targeted at arm64 Linux devices (e.g. Raspberry Pi).

## Dockerfile 

The `Dockerfile` looks as follows:

```Dockerfile
FROM arm64v8/alpine:latest

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
```

### ❗Mapping `audio` Group Inside the Docker Container


When running VLC in a Docker container, the audio devices need to be mapped into the Docker container. This is typically done by mapping the `/dev/snd` folder as a `device` in e.g. your `docker-compose.yaml`, e.g. like this:

```yaml
---
services:
  vlc:
    # [...]
    devices:
      - /dev/snd:/dev/snd  
```

The user executing VLC needs to be part of the `audio` group to have full access to the audio devices. 
However, the `audio` group on the Docker host might have a different group ID than inside the Docker container, which can cause access rights issues with playback failing as the result.

Therefore, this image allows you to map the `audio` group on the Docker host to the `audio` group inside the container.
You can do so by specifying an environment variable named `AUDIO_GID` in your `docker-compose.yaml` and providing the group ID of the `audio` group on the Docker host as a value. 

You can find out the group ID of the `audio` group on the Docker host like this:

```shell
cat /etc/group | grep audio
# Output: audio:x:29:pulse,<username>
```

See also the [`docker-compose.yaml`](docker-compose.yaml) as reference.