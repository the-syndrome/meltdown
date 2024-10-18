# Search

The utility `npm run search-index` spiders the site and creates minimal search index that can then be used by the top right search box.

In the [environment](/deploy/environment) file we set `MELTDOWN_SEARCH_INDEX=true` and the server will run it on boot.

Regenerate it any time

```sh
# as npm script
npm run search-index

# or directly with imba
./node_modules/.bin/imba ./tools/build-search-index.imba
```

If some pages are broken, spidering them can output errors to the console. Unless the HTTP status code is a success (200-299), the page is excluded.