# Two-pipelines convergence demonstration

The headline validation of the protocol-as-method. It runs the
undisciplined
[`adhoc_fa()`](https://sondreskarsten.github.io/operantlunar/reference/adhoc_fa.md)
across a grid of researcher choices (session count, seed count, collapse
rule, seed offset) and the disciplined
[`functional_analysis_replicated()`](https://sondreskarsten.github.io/operantlunar/reference/functional_analysis_replicated.md)
across the same seed offsets, and reports the verdict each yields. The
ad hoc verdict varies with the knobs; the protocol verdict does not. The
residual variability of each is quantified as the number of distinct
verdicts produced.

## Usage

``` r
convergence_demo(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  n_sessions_grid = c(6L, 10L, 20L),
  n_seeds_grid = c(1L, 3L),
  keep_set = c("first", "best", "pool"),
  seed_offsets = c(0L, 100L, 200L),
  n_protocol_subjects = 16L,
  p_reinforce = 0.3,
  p_noise = 0.05,
  response_cost = 0.1,
  session_len = 100L
)
```

## Arguments

- true_function, arms:

  Environment.

- n_sessions_grid:

  Session counts for the ad hoc pipeline.

- n_seeds_grid:

  Seed counts for the ad hoc pipeline.

- keep_set:

  Collapse rules for the ad hoc pipeline.

- seed_offsets:

  Seed offsets applied to both pipelines (subject-pool choice).

- n_protocol_subjects:

  Subject cap for the protocol pipeline.

- p_reinforce, p_noise, response_cost, session_len:

  Environment/run parameters.

## Value

A list with `results` (tibble), `adhoc_distinct`, `protocol_distinct`,
`protocol_verdict`.
