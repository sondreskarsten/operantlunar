# Cumulative record of an agent on a single-operandum schedule

Trains an agent on a one-lever schedule, then returns the cumulative
record of a steady-state tail window.

## Usage

``` r
schedule_record_demo(
  kind = "VR",
  param = 10,
  magnitude = 1,
  response_cost = 0.02,
  agent = "melioration",
  n_steps = 6000L,
  window = 400L,
  seed = 0L
)
```

## Arguments

- kind, param:

  Schedule kind and parameter.

- magnitude, response_cost:

  Reinforcement magnitude and per-response cost.

- agent:

  Registry key for the agent.

- n_steps:

  Total steps.

- window:

  Tail window length for the record.

- seed:

  Seed.

## Value

A tibble cumulative record (see
[`cumulative_record()`](https://sondreskarsten.github.io/operantlunar/reference/cumulative_record.md)).

## Examples

``` r
# \donttest{
schedule_record_demo("VR", 10, n_steps = 4000)
# }
```
