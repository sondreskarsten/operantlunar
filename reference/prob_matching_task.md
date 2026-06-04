# Probability-matching task

Fixed reinforcement probabilities per alternative; one choice per step.
The reward-maximizing policy is exclusive choice of the richer
alternative.

## Usage

``` r
prob_matching_task(probs = c(0.7, 0.3), magnitudes = NULL)
```

## Arguments

- probs:

  Reinforcement probabilities.

- magnitudes:

  Reinforcement magnitudes.

## Value

An environment object with `reset`, `step`, `probs`, `magnitudes`,
`optimal_action`.

## Examples

``` r
env <- prob_matching_task(c(0.7, 0.3))
env$optimal_action
```
