# Ad hoc functional analysis (the undisciplined pipeline)

Deliberately reproduces the researcher degrees of freedom the protocol
removes: a fixed (often too small) number of sessions with no
steady-state check (exogenous stopping), a handful of seeds, and an
arbitrary rule for collapsing them to one verdict (`first` seed, `best`
of K by differentiation magnitude, `majority` vote without a reliability
check, or `pool` which averages rates across subjects). Its verdict is
sensitive to these knobs; that sensitivity is the point of comparison.

## Usage

``` r
adhoc_fa(
  true_function = "escape",
  arms = c("attention", "escape", "tangible", "goal"),
  n_sessions = 8L,
  n_seeds = 3L,
  keep = "first",
  seed0 = 0L,
  session_len = 100L,
  k = 10L,
  p_reinforce = 0.3,
  p_noise = 0.05,
  response_cost = 0.1
)
```

## Arguments

- true_function, arms, session_len, p_reinforce, p_noise, response_cost:

  As elsewhere.

- n_sessions:

  Fixed session count (exogenous stopping).

- n_seeds:

  Seeds run.

- keep:

  Collapse rule: "first", "best", "majority", or "pool".

- seed0:

  Seed offset.

- k:

  Verdict window (capped at `n_sessions`).

## Value

A single verdict string.
