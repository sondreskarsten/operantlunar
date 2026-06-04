# Boltzmann Q-learning agent (softmax selection over Q)

Boltzmann Q-learning agent (softmax selection over Q)

## Usage

``` r
boltzmann_td_agent(alpha = 0.1, gamma = 0.99, beta = 1, n_actions = 4L)
```

## Arguments

- alpha:

  Learning rate.

- gamma:

  Discount factor.

- beta:

  Inverse temperature for selection.

- n_actions:

  Number of actions.

## Value

A list of agent callables.

## Examples

``` r
boltzmann_td_agent()$select
```
