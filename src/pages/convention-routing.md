---
title: Convention routing
---

 The files in `./src/pages` are automatically turned into routes. It's called "Convention Routing" in other projects and we'll use the same name.

Examples

| Page file | HTTP route |
|---|---|
| `./src/pages/about.imba` | `/about` |
| `./src/pages/contact.md` | `/contact` |
| `./src/pages/products/index.imba` | `/products` |
| `./src/pages/products/[productId].imba` | `/products/:productId` |
| `./src/pages/_cant_see_me.imba` | none, hidden |

The parameters are marked with the `:` like `:productId` and standard for most servers.

Filenames starting with an underscore `_` are not made into routes.

## Front Matter

YAML meta data can be added to the top of the markdown pages using Front Matter. It's standard on most static site generators and GitHub-flavored Markdown(GFM) and we use it the same way.

At the top of your markdown page insert the YAML between three dashes. For example `./src/pages/contact.md`

```md
---
title: Contact
description: How to contact us
keywords:
  - contact
  - email
  - phone
---

Our contact info is...
```

In Meltdown, `title:` is the only one we use for setting the HTML `<title>`. If you add any other properties to the Front Matter YAML you can handle extra properties [in the markdown rendering](https://github.com/the-syndrome/meltdown/blob/master/tools/build-routes.imba#L95).