# Procedural-layout gridworld (env_seed sets the apparatus)

A navigation environment whose layout — start cell, the location of each
channel's reward source, and the walls — is fixed by `env_seed`. This
makes the env_seed a genuine setting variable (the apparatus /
contours), distinct from an agent's exploration seed (the subject).
Reaching a source terminates the episode and emits that source's channel
(gated by
[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md));
moving costs `step_cost`; a stay action costs nothing, so under a
no-channel control the agent's best policy is to stay and reach no
source. Navigation is slow to learn, which is the point: it makes
"trained too little" a real source of unreliable conclusions. The
channels are the candidate functions — the agent's own reward sources,
not an imported four-function taxonomy.

## Usage

``` r
procedural_gridworld(
  env_seed = 1L,
  size = 5L,
  arms = c("attention", "escape", "tangible", "goal"),
  n_walls = 4L,
  slip = 0.05,
  magnitude = 1,
  step_cost = 0.04
)
```

## Arguments

- env_seed:

  Seed fixing the layout (the apparatus).

- size:

  Grid side length.

- arms:

  Channel names, one source each.

- n_walls:

  Number of wall cells.

- slip:

  Probability an action is replaced by a random one.

- magnitude:

  Source reinforcement magnitude.

- step_cost:

  Cost per executed move (stay is free).

## Value

A channel environment with `reset`, `step`, `n_actions`, `arms`,
`n_states`, `source_cell`, `start`, `walls`, `size`.
