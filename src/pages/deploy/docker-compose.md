
# Deploy Meltdown with Docker Compose

Set `MELTDOWN_HOST=0.0.0.0` in `.env`.

`./compose.yml`

```yml
version: "3"
services:
  meltdown:
    build:
      context: .
    ports:
      - 33765:33765
    volumes:
      - .:/app
```

```sh
docker-compose up
```

A `Dockerfile` and `compose.yml` are provided in the meltdown repo.
