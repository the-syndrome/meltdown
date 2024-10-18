
# Combine Static Files

Typically there will be three directories with static files of interest.

+ `./assets`
+ `./dist/public`
+ `./.ssg`

It might be useful in your deployment if you combine all the outputs into one directory. For example if serving with nginx or apache, if you combine, you wont have to have a more complicated config testing multiple directories.

```sh
mkdir -p combined

# with SSG
cp -r .ssg/* assets/* dist/public/* combined

# without SSG
cp -r assets/* dist/public/* combined
```

## Testing with sirv-cli

After combining you might want to test the static site and see if everything still works.

```sh
npm install sirv-cli
./node_modules/.bin/sirv --port 33766 combined
```

Open `http://127.0.0.1:33766`

[Test for broken links](/troubleshooting#test-for-broken-links)
