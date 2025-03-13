---
title: Deploy with Docker
---

Set `MELTDOWN_HOST=0.0.0.0` in `.env`.

Build and start the container.

```sh
docker build -t meltdown .
docker run  -it --rm -p 33765:33765 -v .:/app meltdown
```

The `./Dockerfile` included in the repo is not standard. It has some tools for debugging installed within.
