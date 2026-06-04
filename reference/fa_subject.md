# One functional-analysis subject (multielement, trained to steady state)

Runs a single synthetic subject (one `agent_seed`) through a
multielement functional analysis: conditions (the test channels plus a
play control) are presented in randomised order each session, each
session yields one response-rate data point per condition, and the agent
learns condition-specific responding across sessions. Sessions are added
until the steady-state stability criterion is met or `max_sessions` is
reached; the verdict is read from the stabilised window with the
criterion-line rule. Non-stabilisation is reported rather than forced
into a reading.

## Usage

``` r
fa_subject(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  agent = "q_learning",
  agent_seed = 1L,
  session_len = 100L,
  min_sessions = 20L,
  max_sessions = 60L,
  k = 10L,
  tol_trend = 0.1,
  tol_bounce = 0.25,
  p_reinforce = 0.8,
  p_noise = 0.05,
  response_cost = 0.1
)
```

## Arguments

- true_function:

  Hidden maintaining channel.

- arms:

  Test channels.

- agent:

  Registry key for the agent.

- agent_seed:

  The subject's random seed (its identity).

- session_len:

  Trials per condition per session.

- min_sessions, max_sessions:

  Session bounds.

- k:

  Stabilised-window length read for the verdict.

- tol_trend, tol_bounce:

  Stability tolerances.

- p_reinforce, p_noise, response_cost:

  Environment stochasticity.

## Value

A list with `verdict`, `stable`, `n_sessions`, `rates`, `last_k`,
`detail`.
