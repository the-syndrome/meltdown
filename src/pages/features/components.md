
# Components

## nav-link

The `<nav-link>` component allows instant navigation between pages without reloading the page.

```imba
<nav-link to="/path/to/page"> "Title"

<nav-link to="/path/to/page">
  <thin-icon name="pen>
  "Edit"
```

If you don't want to use it please refer to [imba router](https://imba.io/docs/router). e.g. `<a route-to="/some/path">` or `imba.router.go "/some/other/path"`

## thin-icon

```imba
<thin-icon name="pencil">
<thin-icon name="pen">
<thin-icon name="wrench">
<thin-icon name="gear">
```

Search a gazillion of them at <https://phosphoricons.com>.

## text-copier

It shows a little copy icon that can be clicked to copy text.

```imba
# static
<text-copier value="my code to be copied">

# from a variable
const myCodes = "my dynamic code"
<text-copier value=myCodes>
```
