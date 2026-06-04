# Differential-reinforcement (DRA/FCT) chamber

Two responses share one maintaining reinforcer. Action 1 is the problem
response, action 2 the appropriate alternative. `set_reinforced()`
switches which response currently produces the reinforcer, so a baseline
(problem reinforced) can be followed by treatment (alternative
reinforced, problem on extinction) — the contingency engine under DRA
and functional communication training.

## Usage

``` r
dra_chamber(magnitude = 1, response_cost = 0)
```

## Arguments

- magnitude:

  Reinforcement magnitude.

- response_cost:

  Cost per response.

## Value

An environment object with `reset`, `step`, and `set_reinforced`.

## Examples

``` r
ch <- dra_chamber()
ch$reset(seed = 0)
ch$step(1)
```
