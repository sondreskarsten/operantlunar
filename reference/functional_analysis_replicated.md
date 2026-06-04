# Replicated functional analysis to a reliability conclusion (no pooling)

Runs many synthetic subjects (one per `agent_seed`), each individually
trained to steady state and given a criterion-line verdict, and adds
subjects until the reliability of the conclusion stabilises (the
modal-verdict agreement among stabilised subjects changes by at most
`reliability_tol` over the last `reliability_window` subjects) or
`n_subjects` is reached. The conclusion is the reliability summary,
computed at read time from the per-subject verdicts: response rates are
never pooled across subjects, because averaging subjects who differ
manufactures a group function that no subject has. This is the
idiographic replication logic that replaces a single seed or best-of-K.

## Usage

``` r
functional_analysis_replicated(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  agent = "q_learning",
  n_subjects = 20L,
  min_subjects = 10L,
  reliability_window = 5L,
  reliability_tol = 0.1,
  seed0 = 0L,
  session_len = 100L,
  min_sessions = 20L,
  max_sessions = 50L,
  k = 10L,
  tol_trend = 0.1,
  tol_bounce = 0.25,
  p_reinforce = 0.3,
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

- n_subjects:

  Maximum subjects.

- min_subjects:

  Minimum before the reliability stopping rule applies.

- reliability_window, reliability_tol:

  Endogenous meta-stopping parameters.

- seed0:

  Offset added to subject indices (so disjoint subject pools are
  possible).

- session_len, min_sessions, max_sessions, k, tol_trend, tol_bounce:

  Per-subject parameters.

- p_reinforce, p_noise, response_cost:

  Environment stochasticity.

## Value

A list with `subjects` (tibble), `summary` (tibble), `modal_verdict`,
`agreement`.
