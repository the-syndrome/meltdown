---
title: Deploy Environment
---

It's explained in the [setup](https://meltdown.dex.yachts/setup-meltdown) to create the `.env` file. The default variables are:

+ `PORT=33765`, http server port
+ `POCKETBASE_URL=http://127.0.0.1:8090`, optional, if you're using [pocketbase](https://meltdown.dex.yachts/setup-pocketbase).
+ `SITE_KEY=meltdown`, optional, if using pocketbase

Any others you use are optional. For security purposes, please make sure secrets don't get bundled into `./dist` when you build.