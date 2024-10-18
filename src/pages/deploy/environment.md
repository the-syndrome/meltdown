---
title: Deploy Environment
---

It's explained in the [setup](https://meltdown.dex.yachts/get-started) to create the `.env` file. The default variables are:

+ `MELTDOWN_PORT=33765`, http server port
+ `MELTDOWN_HOST=127.0.0.1`, http server port
+ `MELTDOWN_STATE1=iNEmQL`, required, used for initial page state
+ `MELTDOWN_STATE2=JW29a4`, required, used for initial page state
+ `MELTDOWN_SEARCH_INDEX=false`, optional, defaults to `true` for [Search feature](/features/search)
+ `MELTDOWN_SSG=true`, optional, defaults to `false` and is used for the [SSG feature](/features/ssg).

Any others you use are optional. For security purposes, please make sure secrets don't get bundled into `./dist` when you build.
