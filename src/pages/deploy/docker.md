---
title: Deploy with Docker
---

This is an example of a `./Dockerfile` you can use.

```dockerfile
FROM node:22-alpine3.20
ENV NODE_ENV=production
RUN mkdir /app
WORKDIR /app
RUN npm install --ignore-scripts && npm rebuild esbuild
CMD ["npm", "start"]
```

Start

```sh
docker build -t meltdown .
docker run  -it --rm -p 33765:33765 -v .:/app meltdown
```
