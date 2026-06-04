# Single-operandum operant chamber

Actions: 1 = respond, 2 = withhold. Levers: reinforcement magnitude,
punishment probability/magnitude, response cost, and extinction.

## Usage

``` r
operant_chamber(
  schedule = NULL,
  magnitude = 1,
  punish_prob = 0,
  punish_mag = 1,
  response_cost = 0,
  extinction = FALSE
)
```

## Arguments

- schedule:

  A schedule object.

- magnitude:

  Reinforcement magnitude.

- punish_prob, punish_mag:

  Punishment contingency.

- response_cost:

  Cost subtracted per response.

- extinction:

  Whether reinforcement is withheld.

## Value

An environment object with `reset`, `step`, and `set_extinction`.

## Examples

``` r
ch <- operant_chamber()
ch$reset(seed = 0)
ch$step(1)
```
