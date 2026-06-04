# Fixed-interval temporal-control demonstration

Trains a softmax value agent on
[`fi_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/fi_chamber.md)
and summarises responding as a function of time since the last
reinforcer. A reward-driven agent withholds early and responds
near/after the interval (break-and-run temporal control); the smoothly
graded biological scallop requires temporal generalisation that a
tabular agent lacks.

## Usage

``` r
fi_temporal_demo(
  interval = 20,
  beta = 6,
  alpha = 0.1,
  gamma = 0.99,
  response_cost = 0.15,
  n_steps = 30000L,
  window = 8000L,
  seed = 0L
)
```

## Arguments

- interval:

  Fixed interval in steps.

- beta:

  Softmax inverse temperature.

- alpha, gamma:

  Learning rate and discount.

- response_cost:

  Cost per response.

- n_steps:

  Total steps.

- window:

  Tail window for the summary.

- seed:

  Seed.

## Value

A list with `by_time` (tibble of response rate by elapsed time) and a
`record` cumulative record.

## Examples

``` r
# \donttest{
fi_temporal_demo(interval = 20, n_steps = 30000)
# }
```
