
# Markdown

With [Convention Routing](/features/convention-routing) any markdown files you put in `./src/pages` will be transformed to a route and a page. e.g. `./src/pages/about.md` available at `/about` route.

👈 At the left a table of contents is automatically generated. See [Front Matter](/features/front-matter) to enable, disable, or move to the right.

## Blockquote

```md
> Alpha bravo charlie.
```

> Alpha bravo charlie.

## break

With two spaces at the end.

```md
one  
two  
three
```

one  
two  
three

With slashes

```md
four\
five\
six
```

four\
five\
six

## code

````md
```js
function test() {
  console.liog("ok")
}
```
````

```js
function test() {
  console.liog("ok")
}
```

Syntax highlighting is done by `shiki` module. Supported language syntax highlighting: <https://shiki.style/languages>

## definition

```md
[Alpha]: https://example.com
```

[Alpha]: https://example.com

Footnote definition

```md
[^alpha]: bravo and charlie.
```

[^alpha]: bravo and charlie.

Footnote reference

```md
[^alpha]
```

[^alpha]

## delete

GFM delete / strike

```md
~spicy redacted~
```

~spicy redacted~

## emphasis

```md
*alpha* _bravo_
```

*alpha* _bravo_

## heading

```md
# heading1
## heading2
### heading3
```

## html

```html
<div style="border: 3px solid green">green html box</div>
```

<div style="border: 3px solid green">green html box</div>

## image

```md
![img alt](/favicon/favicon-16x16.png "img title")
```

![img alt](/favicon/favicon-16x16.png "img title")

## imageReference

```md
![alpha][bravo]
```

![alpha][bravo]

## inlineCode

```md
We like to `code` things.
```

We like to `code` things.

## link

```md
[Home](/)
[Home](/ "with title")
```

[Home](/)
[Home hover cursor](/ "with title")

## linkReference

```md
[alpha][Bravo]
```

[alpha][Bravo]

## list

Unordered

```md
+ Sally
+ Timmy
+ Oliver
```

+ Sally
+ Timmy
+ Oliver

Ordered

```md
1. one
2. two
3. three
```

1. one
2. two
3. three

Checks (fix me)

```md
+ [ ] Things
+ [x] I want
+ [ ] To do
```

+ [ ] Things
+ [x] I want
+ [ ] To do

## paragraph

```md
Alpha bravo charlie.
```

Alpha bravo charlie.

## root

Root is a collection of other nodes.

## strong

```md
**alpha** __bravo__
```

**alpha** __bravo__

## text

```md
Alpha bravo charlie.
```

Alpha bravo charlie.

## thematicBreak

Asterisks

```md
***
```

***

Dashes

```md
---
```

---

## table

```md
| left aligned | centered | right aligned |
| :-- | :-: | --: |
| 👈 | 😎 | 👉 |
```

| left aligned | centered | right aligned |
| :-- | :-: | --: |
| 👈 | 😎 | 👉 |
