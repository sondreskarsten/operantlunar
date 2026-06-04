# Configure the Python environment for LunarLander

Call once before
[`make_lunar()`](https://sondreskarsten.github.io/operantlunar/reference/make_lunar.md).
With `python = NULL` the Gymnasium dependency is declared via
[`reticulate::py_require()`](https://rstudio.github.io/reticulate/reference/py_require.html)
so it is provisioned automatically (including on Posit Connect /
shinyapps.io). Supply a path to reuse an existing interpreter that
already has `gymnasium[box2d]`.

## Usage

``` r
lunar_setup(python = NULL)
```

## Arguments

- python:

  Optional path to a Python interpreter.

## Value

Invisibly `TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup()
} # }
```
