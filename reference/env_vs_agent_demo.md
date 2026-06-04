# Apparatus (env_seed) versus subject (agent_seed) demonstration

Crosses several layout seeds with several agent seeds on the procedural
gridworld and reports each subject's verdict, stability, and sessions to
steady state. The env_seed is a setting variable: it changes the
apparatus (path lengths, wall placement) and therefore systematically
shifts difficulty (sessions to stability), whereas the agent_seed
indexes interchangeable subjects within an apparatus. Holding these on
separate grains is what keeps a non-influential seed out of scope and
prevents pooling subjects who differ.

## Usage

``` r
env_vs_agent_demo(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  env_seeds = 1:4,
  agent_seeds = 1:4,
  episodes_per_session = 15L,
  min_sessions = 22L,
  max_sessions = 50L,
  k = 10L,
  max_steps = 40L,
  size = 6L,
  n_walls = 6L,
  slip = 0.05,
  step_cost = 0.04
)
```

## Arguments

- true_function, arms:

  Environment.

- env_seeds:

  Layout seeds (apparatus).

- agent_seeds:

  Subject seeds.

- episodes_per_session, min_sessions, max_sessions, k, max_steps, size,
  n_walls, slip, step_cost:

  Gridworld parameters.

## Value

A tibble with `env_seed`, `agent_seed`, `verdict`, `stable`,
`n_sessions`.
