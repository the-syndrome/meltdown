
# Convention routing

The files in `./src/pages` are automatically turned into routes. It's called "Convention Routing" in other projects and we'll use the same name.

Examples

| Page file | HTTP route |
|---|---|
| `./src/pages/about.imba` | `/about` |
| `./src/pages/contact.md` | `/contact` |
| `./src/pages/help.html` | `/help` |
| `./src/pages/products/index.imba` | `/products` |
| `./src/pages/products/[productId].imba` | `/products/:productId` |
| `./src/pages/_cant_see_me.imba` | none, hidden |

The parameters are marked with the `:` like `:productId` and standard for most servers.

Filenames starting with an underscore `_` are not made into routes.
