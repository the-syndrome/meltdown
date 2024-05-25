
# meltdown

Meltdown is a concept for an isomorphic [imba](https://imba.io) framework with SSR, SPA, and SSG modes. In the current form it's a template. In the future we can develop it into a framework or a better template.

Demo, docs, and community → <https://meltdown.dex.yachts>

Features

+ Client rendering: SPA mode
+ Server rendering: SSR mode
+ Convention routing with `./src/pages`
+ Instant and seemless navigation between pages
+ Dynamic loading data from API

Future & Todo

+ Server-side generation: SSG mode
+ Error pages
+ Markdown pages e.g. `./src/pages/about.md` becomes `/about` page
+ Layouts
+ Other things inspired by vike, next.js, hexo, hugo, astro, nuxt, etc.

Collaborators welcome! Join [the imba chat](https://discord.gg/mkcbkRw) and msg `@the_syndrome`.

## Install

```sh
git clone https://github.com/the-syndrome/meltdown.git my-site
cd my-site
npm install --ignore-scripts
npm rebuild esbuild
cp .env.example .env
```

The `.env` file is configured to your needs.

## Dev

```sh
npm run dev
```

Open <http://127.0.0.1:33765>

## Guides

+ Setup meltdown <https://meltdown.dex.yachts/setup-meltdown>
+ Setup pocketbase <https://meltdown.dex.yachts/setup-pocketbase>
+ Deploy Environment <https://meltdown.dex.yachts/deploy/environment>
+ Deploy with Docker <https://meltdown.dex.yachts/deploy/docker>

## Deploy

In production, the default script is usually `npm start`, so we followed that convention too. It will build the page routes, transpile the server and client source, and then start the server. This flow will work for most. If you're app is huge, you may want to optimize it.

```sh
npm start # setup, build, and run server process
```
