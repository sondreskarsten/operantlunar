# Contingency-sensitivity (reversal) probe

Trains one subject to steady state under a baseline contingency (engage
reinforced under the `true_function` discriminative stimulus), then
reverses the contingency so engage is reinforced under the
`reversal_function` stimulus instead, and measures whether behaviour
tracks the change while learning continues. Behaviour that re-allocates
to the new contingency is contingency-sensitive; behaviour that
perseveres on the old stimulus is insensitive, the signature of a policy
that no longer tracks its environment (off-distribution brittleness).
This is the ABAB reversal logic applied to a synthetic subject.

## Usage

``` r
reversal_probe(
  true_function = "escape",
  reversal_function = "attention",
  arms = c("attention", "escape", "tangible", "goal"),
  agent_seed = 1L,
  session_len = 100L,
  train_sessions = 25L,
  probe_sessions = 15L,
  k = 10L,
  p_reinforce = 0.8,
  p_noise = 0.05,
  response_cost = 0.1
)
```

## Arguments

- true_function:

  Baseline maintaining stimulus.

- reversal_function:

  Post-reversal maintaining stimulus.

- arms:

  Channels.

- agent_seed:

  Subject seed.

- session_len:

  Trials per condition per session.

- train_sessions, probe_sessions:

  Baseline and reversal session counts.

- k:

  Window read for post-reversal rates.

- p_reinforce, p_noise, response_cost:

  Environment stochasticity.

## Value

A list with `rates` (tibble with `phase`), `tracked`, `summary`.
