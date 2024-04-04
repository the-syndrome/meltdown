
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

Open <http://127.0.0.1:3000>

## Guides

+ Setup meltdown <https://meltdown.dex.yachts/setup-meltdown>
+ Setup pocketbase <https://meltdown.dex.yachts/setup-pocketbase>

## Screens and routes

If you create new screens add them to `./src/routes.imba`.

## Deploy

```sh
npm run build
npm run generate
```
