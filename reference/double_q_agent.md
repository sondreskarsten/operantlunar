# Double Q-learning agent (de-biased maximization)

Double Q-learning agent (de-biased maximization)

## Usage

``` r
double_q_agent(
  alpha = 0.1,
  gamma = 0.99,
  eps_start = 1,
  eps_end = 0.05,
  eps_decay_steps = 150000,
  n_actions = 4L
)
```

## Arguments

- alpha:

  Learning rate.

- gamma:

  Discount factor.

- eps_start, eps_end, eps_decay_steps:

  Epsilon schedule.

- n_actions:

  Number of actions.

## Value

A list of agent callables.

## Examples

``` r
names(double_q_agent())
```
