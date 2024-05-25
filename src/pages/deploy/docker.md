---
title: Deploy with Docker
---

This is an example of a `./Dockerfile` you can use.

```dockerfile
ARG NODE_VERSION=18.20.2
FROM node:${NODE_VERSION}-slim
ENV NODE_ENV=production
RUN apt-get update -qq && \
  apt-get install -y python-is-python3 pkg-config build-essential
RUN mkdir /app
WORKDIR /app
COPY data /app/data
COPY src /app/src
COPY tools /app/tools
COPY .env .npmrc package.json /app
RUN npm install --ignore-scripts && npm rebuild esbuild
CMD ["npm", "start"]
```

Start

```sh
PROJECT=meltdown # replace with your project name
PORT=33765 # matching your .env PORT
podman build -t meltdown .
podman run  -it --rm -p $PORT:$PORT $PROJECT
```
