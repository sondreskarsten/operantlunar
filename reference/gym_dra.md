# Differential reinforcement (DRA) on a Gymnasium-style gridworld

Trains the agent to navigate to a problem arm (baseline), then switches
the active channel so the problem arm is on extinction and an
alternative arm is reinforced (treatment). Behaviour reallocates from
the problem arm to the alternative: the contingency engine behind
DRA/FCT on a multi-state navigation task.

## Usage

``` r
gym_dra(
  arms = c("problem", "alternative"),
  corridor = 3L,
  agent = "q_learning",
  n_baseline = 400L,
  n_treatment = 600L,
  window = 50L,
  max_steps = 20L,
  seed = 0L
)
```

## Arguments

- arms:

  Two channel names, `c(problem, alternative)`.

- corridor:

  Arm length.

- agent:

  Registry key for the agent.

- n_baseline, n_treatment:

  Episodes per phase.

- window:

  Episodes per summary window.

- max_steps:

  Step cap per episode.

- seed:

  Seed.

## Value

A tibble with `window_mid`, `arm`, `reach_rate`, `switch_ep`.

## Examples

``` r
# \donttest{
gym_dra()
# }
```
