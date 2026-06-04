# Model-based planning agent (goal-directed control)

Learns a tabular transition/reward model and acts greedily with respect
to a value function refreshed by periodic value iteration. Intended for
small discrete environments; the model is exact rather than
approximated.

## Usage

``` r
model_based_agent(
  gamma = 0.99,
  eps_start = 1,
  eps_end = 0.05,
  eps_decay_steps = 150000,
  n_actions = 4L,
  replan_every = 200L,
  vi_sweeps = 30L
)
```

## Arguments

- gamma:

  Discount factor.

- eps_start, eps_end, eps_decay_steps:

  Epsilon schedule.

- n_actions:

  Number of actions.

- replan_every:

  Steps between value-iteration refreshes.

- vi_sweeps:

  Sweeps per refresh.

## Value

A list of agent callables.

## Examples

``` r
names(model_based_agent())
```
