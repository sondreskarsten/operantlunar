# Steady-state stability of a per-condition rate series

A Sidman-tradition stability criterion applied to the last `k` sessions
of each condition's response-rate series: stable when there is no trend
(the first-half and second-half means of the window differ by at most
`tol_trend`) and bounce is bounded (the window range is at most
`tol_bounce`), for every condition. This is the endogenous stopping rule
that replaces an arbitrary fixed number of sessions.

## Usage

``` r
stability_reached(rates, k = 10L, tol_trend = 0.1, tol_bounce = 0.25)
```

## Arguments

- rates:

  A tibble with `session`, `condition`, `rate`.

- k:

  Window length (most recent sessions).

- tol_trend:

  Maximum allowed half-split mean difference within the window.

- tol_bounce:

  Maximum allowed range within the window.

## Value

`TRUE` if every condition is stable over the last `k` sessions.
