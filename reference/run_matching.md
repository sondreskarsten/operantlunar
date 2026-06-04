# Run a melioration agent on a concurrent VI schedule

Run a melioration agent on a concurrent VI schedule

## Usage

``` r
run_matching(agent, vi_means = c(30, 90), n_steps = 20000L, seed = 0L)
```

## Arguments

- agent:

  An agent (see
  [`melioration_agent()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_agent.md)).

- vi_means:

  Mean intervals.

- n_steps:

  Number of responses.

- seed:

  Seed.

## Value

A list with response counts `B` and reinforcer counts `R`.
