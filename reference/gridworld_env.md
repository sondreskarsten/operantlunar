# Composite-reward gridworld (Gymnasium-style)

A hub-and-spoke navigation task: from the hub, each action commits
toward one arm; staying on an arm advances to its end, choosing another
arm retreats. Reaching an arm's end terminates the episode and emits
that arm's reinforcement channel; every step costs `step_cost`. With
[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md)
the active channel determines which arm pays, so the agent navigates to
the reinforced arm.

## Usage

``` r
gridworld_env(
  arms = c("attention", "escape", "tangible", "goal"),
  corridor = 3L,
  magnitude = 1,
  step_cost = 0.02
)
```

## Arguments

- arms:

  Channel names, one per arm.

- corridor:

  Steps from hub to an arm end.

- magnitude:

  Terminal reinforcement magnitude.

- step_cost:

  Per-step cost (always applied).

## Value

A channel environment with `reset`, `step`, `n_actions`, `arms`,
`n_states`.
