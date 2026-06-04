# Operant-conditioning glossary

A beginner-oriented reference of core operant-conditioning concepts,
each with a short verified definition, its primary source, and the
handbook(s) in the bundled corpus that cover it. Definitions were
checked against the literature before entry; see
[`operant_bibliography()`](https://sondreskarsten.github.io/operantlunar/reference/operant_bibliography.md)
for the sources.

## Usage

``` r
operant_glossary()
```

## Value

A tibble with columns `term`, `category`, `definition`,
`primary_source`, `handbook`.

## Examples

``` r
g <- operant_glossary()
unique(g$category)
g[g$category == "Choice and dynamics", c("term", "definition")]
```
