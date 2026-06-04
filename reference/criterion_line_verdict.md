# Criterion-line functional-analysis verdict (Hagopian et al., 1997)

Applies the structured, reproducible interpretation rule from Hagopian
et al. (1997) (as described in Fisher et al., 2021): draw an upper and
lower criterion line one standard deviation above and below the
control-condition mean; for each test condition, count session points
above the upper line minus points below the lower line; the condition is
differentiated when that difference is at least half the number of data
points. This replaces subjective visual analysis with a fixed
quantitative decision so the verdict is not a researcher degree of
freedom.

## Usage

``` r
criterion_line_verdict(
  last_k,
  arms = c("attention", "escape", "tangible", "goal"),
  control = "play"
)
```

## Arguments

- last_k:

  A tibble with `session`, `condition`, `rate` (the stabilised window).

- arms:

  Test channels.

- control:

  Control condition name.

## Value

A list with `verdict`, `differentiated`, `detail` (per-condition D and
threshold).
