# DRA / FCT reallocation demonstration

Trains a reward-driven agent on
[`dra_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/dra_chamber.md)
through a baseline phase (the problem response is reinforced) and a
treatment phase (the problem response is put on extinction and an
alternative response is reinforced), then summarises the proportion of
each response over time. Behaviour reallocates from the problem to the
alternative — the mechanism behind differential reinforcement of an
alternative behaviour.

## Usage

``` r
dra_fct_demo(
  baseline = 4000L,
  treatment = 8000L,
  agent = "q_learning",
  magnitude = 1,
  window = 300L,
  seed = 0L
)
```

## Arguments

- baseline, treatment:

  Steps per phase.

- agent:

  Registry key for the agent.

- magnitude:

  Reinforcement magnitude.

- window:

  Window length for the proportion summary.

- seed:

  Seed.

## Value

A tibble with `window_mid`, `response`, `rate`, `switch_step`.

## Examples

``` r
# \donttest{
dra_fct_demo()
# }
```
