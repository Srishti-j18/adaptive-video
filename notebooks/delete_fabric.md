::: {.cell .markdown}
### Delete your slice
:::

::: {.cell .markdown}
When you finish your experiment, you should delete your slice! The following cells deletes all the resources in your slice, freeing them for other experimenters.
:::

::: {.cell .code}
``` python
slice = fablib.get_slice(name=slice_name)
fablib.delete_slice(slice_name)
```
:::

::: {.cell .code}
``` python
# slice should end up in "Dead" state
# re-run this cell until you see it in "Dead" state
slice.update()
_ = slice.show()
```
:::
