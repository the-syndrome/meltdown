
# Static Site Generation (SSG)


The script `npm run ssg` will request all the HTML pages and save them to the `.ssg` directory. In the [environment](/deploy/environment) file we set `MELTDOWN_SSG=true` and the server will run it on boot.

Regenerate it any time manually. Currently it requires the server to be running.

```sh
# as npm script
npm run ssg

# or directly with imba
./node_modules/.bin/imba ./tools/build-ssg.imba
```

Unless the HTTP status code is a success (200-299), the page is excluded from the search index. If `printSummary` is `true` in the script the errors will display in the console when you run it manually.
