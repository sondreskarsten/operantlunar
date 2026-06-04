# Differentiate rules on a tabular Gymnasium environment

Trains rules on a discrete-observation environment (e.g. FrozenLake) and
reports success rate under the learned policy. Maximizing rules
propagate the terminal reward; myopic melioration cannot.

## Usage

``` r
differentiate_gym(
  id = "FrozenLake-v1",
  rules = c("q_learning", "melioration", "model_based"),
  n_train = 2000L,
  n_eval = 200L,
  max_steps = 200L,
  seed = 0L,
  make_kwargs = list(is_slippery = TRUE)
)
```

## Arguments

- id:

  Gymnasium environment id.

- rules:

  Registry keys.

- n_train, n_eval:

  Episode counts.

- max_steps:

  Step cap per episode.

- seed:

  Seed.

- make_kwargs:

  List passed to `gymnasium.make`.

## Value

A list with the env id and a tibble of per-rule results.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup("/usr/bin/python3")
differentiate_gym("FrozenLake-v1", n_train = 1500, make_kwargs = list(is_slippery = FALSE))
} # }
```
