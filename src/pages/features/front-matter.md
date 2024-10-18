# Front Matter

YAML meta data can be added to the top of the markdown pages using Front Matter. It's standard on most static site generators and GitHub-flavored Markdown(GFM) and we use it the same way.

At the top of your markdown page insert the YAML between three dashes. For example `./src/pages/contact.md`

```md
---
title: Contact
toc: false
---

Our contact info is...
```

## title

Override any `H1` a.k.a. `# Heading 1` with something else.

```md
---
title: My other title
---
```

## toc

Generate a table of contents for pages that have a bunch of headings.

```md
---
toc: true
---
```

+ `toc: true`, default, on left
+ `toc: false`, don't show it at all
+ `toc: left`, force left
+ `toc: right`, force right

## keywords

Write keywords into the HTML meta tags.

```md
---
keywords:
  - contact
  - email
  - phone
---
```

## description

Write a description to the HTML meta tags.

```md
---
description: My page is the best page.
---
```

## Customizing front matter

If you add any other properties to the Front Matter YAML you can handle extra properties [in the markdown rendering](https://github.com/the-syndrome/meltdown/blob/master/tools/build-routes.imba). See `def markdownToAst` for how the markdown is processed through [unified](https://unifiedjs.com).

