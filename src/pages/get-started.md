
# Get Started with Meltdown

```sh
git clone https://github.com/the-syndrome/meltdown.git my-site
cd my-site
cp .env.example .env
npm install --ignore-scripts
npm rebuild esbuild
npm run dev
```

By default it runs on `http://127.0.0.1:33765`, so port `33765`.

## Create pages

+ [Convention routing](/features/convention-routing)
+ [Markdown pages](/features/markdown)
+ [HTML pages](/features/html)
+ [Dynamic pages (*.imba, *.js, *.ts)](/features/dynamic-data)

## Assets

You can add and modify what is in `./assets`, add your own images, and favicon. These files will be served as static files in development.

Consider editing or deleting:

+ `./assets/robots.txt` blank by default
+ `./assets/favicon` get an [emoji favicon](https://favicon.io/emoji-favicons/) or drop your own in there

## Environment

Optionally, customize the [Environment (.env)](/deploy/environment) file to enable or disable features.

## Debloat

By default the project has the content for [meltdown.dex.yachts](https://meltdown.dex.yachts) docs site. To quickly remove it and "debloat" run:

```sh
rm -rf src/pages/deploy
rm -rf src/pages/features
rm -rf src/pages/troubleshooting
rm -rf src/pages/get-started.md
rm -rf src/pages/debug.imba
```

## package.json

If working with a team you might want to customize `package.json` and add your own `name`, `description`, and `version`.

```json
{
  "name": "meltdown",
  "description": "meltdown imba site template",
  "version": "0.2.0"
}
```
