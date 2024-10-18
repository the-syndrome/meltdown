
# meltdown

Meltdown is a concept for an isomorphic [imba](https://imba.io) framework with SSR, SPA, and SSG modes. In the current form it's a template. In the future we can develop it into a framework or a better template.

Demo, docs, and community → <https://meltdown.dex.yachts>

Features

+ Instant navigation between pages
+ [Convention routing](https://meltdown.dex.yachts/features/convention-routing) with `./src/pages/*`
+ [Markdown pages](https://meltdown.dex.yachts/features/markdown-pages) e.g. `./src/pages/about.md` becomes `/about` page
+ [HTML pages](https://meltdown.dex.yachts/features/html-pages) e.g. `./src/pages/contact.html` becomes `/contact` page
+ [Dynamic pages](https://meltdown.dex.yachts/features/dynamic-pages) e.g. `./src/pages/blog.imba` becomes `/blog` page, supports `*.imba`, `*.js`, and `*.ts` pages
+ [Some components](https://meltdown.dex.yachts/features/components) to get you started `./src/components`
+ [Front matter](https://meltdown.dex.yachts/features/front-matter)
+ Server rendering: [SSR mode](https://meltdown.dex.yachts/features/dynamic-pages)
+ [Static site generation (SSG)](https://meltdown.dex.yachts/features/ssg)
+ [Search](https://meltdown.dex.yachts/features/search) indexer, no need for Algolia, it's built-in

Future goals

+ Improve base design
+ Improve error pages
+ Incremental SSG
+ Improve search, show sections, headings, excerpts
+ Light & dark mode
+ Automate GH pages & other static services

Collaborators are welcome. Join [the imba chat](https://discord.gg/mkcbkRw) and msg `@the_syndrome`. File an [issue](https://github.com/the-syndrome/meltdown/issues) if there is a problem.

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

+ [Setup meltdown](https://meltdown.dex.yachts/get-started)
+ [Deploy Environment](https://meltdown.dex.yachts/deploy/environment)
+ [Deploy with Docker](https://meltdown.dex.yachts/deploy/docker)
+ [Deploy with Docker Compose](https://meltdown.dex.yachts/deploy/docker-compose)

### Headless CMS

+ [Deploy with Pocketbase](https://meltdown.dex.yachts/deploy/with-pocketbase)
+ [Deploy with Directus](https://meltdown.dex.yachts/deploy/with-directus)
+ [Deploy with Grav](https://meltdown.dex.yachts/deploy/with-grav)

## Deploy

In production, the default script is usually `npm start`, so we followed that convention too. It will build the page routes, transpile the server and client source, and then start the server. This flow will work for most. If you're app is huge, you may want to optimize it.

```sh
npm start # setup, build, and run server process
```

## Troubleshooting

+ [meltdown.dex.yachts](https://meltdown.dex.yachts) Troubleshooting section
+ [Community](https://meltdown.dex.yachts) join chat or make issues
