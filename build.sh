#!/bin/zsh

docker buildx create --name raspibuilder
docker buildx use raspibuilder
docker buildx build --platform linux/arm64 -t fwinkler79/arm64v8-vlc-docker:1.0.0 --push .