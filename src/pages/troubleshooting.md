
# Troubleshooting Meltdown

## Debug page

If `NODE_ENV` is not `production` the developer can view [/debug](/debug) displaying a summary of pages in the site and info about each.

## Unmemoized nodes

If you see an error in the console such as:

```
Trace: detected unmemoized nodes in [
  <ref *1> SiteClient {
```

There might be an issue where the content of a tag is `null` or `undefined`.

Ways to troubleshoot:

1. Comment out some HTML tags you recently added.
2. Debug the values of dynamic values e.g. `<div> "val: {JSON.stringify(val)}"`
3. Search for browser-only variables `window.*` or `navigator.*`
4. Enable `imba --inspect` in the script `npm run dev-server` in `package.json`

It can be a difficult challenge to trace down precisely what is causing it. We can work with the imba team to make it easier in the future.

## Server keeps restarting

There might be some files that are frequently changed thus causing a server restart. The imba tooling uses the [ignore](https://github.com/kaelzhang/node-ignore#readme) module so something you can try is adding the files that are changing to `.gitignore`.

## Unexpected end of file in JSON

An educated guess is that when Meltdown is writing files to disk, and while they are still being written, imba+esbuild are trying to read and parse them before it's done.

The console error looks like:

`✘ [ERROR] Unexpected end of file in JSON`

We'll work together with the community to figure out a solution. For the time being it might just print the error and try again and succeed.

## Test for broken links

Search indexer

```sh
# the output includes 404 and 500 errors
npm run search-index
```

Linkinator ⚠️ At this time it wont obey `--include` and it will spider all links, including some or all external links.

```sh
npm install linkinator

# default site port
./node_modules/.bin/linkinator http://127.0.0.1:33765
```

wget

```sh
wget --spider -o wget-spider.log -e robots=off -r -p http://127.0.0.1:33765

# missing
cat wget-spider.log | grep ' 404 '

# errors
cat wget-spider.log | grep ' 500 '
```
