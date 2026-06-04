# One functional-analysis subject on the procedural gridworld

The gridworld analogue of
[`fa_subject()`](https://sondreskarsten.github.io/operantlunar/reference/fa_subject.md):
a single subject (one `agent_seed`) at a fixed `env_seed` (the apparatus
held constant, as a real functional analysis holds the chamber constant
across replications). Conditions (each channel active, plus a play
control) alternate by session; each session's data point is the
proportion of episodes that reach the target source (the source tied to
`true_function`). Reaching the target is reinforced only when its
channel is active, so the target-reach rate is elevated only under the
maintaining condition. Sessions are added until steady state or
`max_sessions`; the verdict uses the criterion-line rule.

## Usage

``` r
fa_subject_gridworld(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  env_seed = 1L,
  agent_seed = 1L,
  n_sessions = NULL,
  episodes_per_session = 20L,
  min_sessions = 25L,
  max_sessions = 70L,
  k = 10L,
  tol_trend = 0.12,
  tol_bounce = 0.3,
  max_steps = 40L,
  size = 5L,
  n_walls = 4L,
  slip = 0.05,
  step_cost = 0.04
)
```

## Arguments

- true_function:

  Hidden maintaining channel.

- arms:

  Channels.

- env_seed:

  Layout seed (apparatus).

- agent_seed:

  Subject seed.

- n_sessions:

  If non-NULL, run exactly this many sessions (exogenous stopping); else
  steady-state.

- episodes_per_session:

  Episodes per condition per session.

- min_sessions, max_sessions:

  Session bounds for steady-state mode.

- k:

  Stabilised-window length.

- tol_trend, tol_bounce:

  Stability tolerances.

- max_steps:

  Step cap per episode.

- size, n_walls, slip, step_cost:

  Environment parameters.

## Value

A list with `verdict`, `stable`, `n_sessions`, `rates`, `last_k`,
`detail`.
