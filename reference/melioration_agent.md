# Melioration agent (myopic linear-operator preference)

A gradient-bandit reinforcement-preference rule: no temporal
bootstrapping, probability-matching selection. Reproduces the matching
law.

## Usage

``` r
melioration_agent(alpha = 0.1, beta = 1, n_actions = 4L, baseline = TRUE)
```

## Arguments

- alpha:

  Learning rate.

- beta:

  Inverse temperature for selection.

- n_actions:

  Number of actions.

- baseline:

  Whether to subtract a per-state running-mean reward baseline.

## Value

A list of agent callables.

## Examples

``` r
b <- melioration_agent()
names(b)
```
