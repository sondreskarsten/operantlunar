# Differentiate rules under linear function approximation

Trains linear SARSA (bootstrapping) and linear melioration (myopic) on a
Gymnasium environment with shared tile features. This is the function-
approximation analogue of the tabular differentiation, and the intended
way to make the LunarLander comparison conclusive rather than a binning
artifact.

## Usage

``` r
differentiate_fa(
  id = "CartPole-v1",
  n_train = 300L,
  n_eval = 20L,
  max_steps = 500L,
  n_tilings = 8L,
  bins = 8L,
  table_size = 8192L,
  seed = 0L,
  make_kwargs = list()
)
```

## Arguments

- id:

  Gymnasium environment id.

- n_train, n_eval:

  Episode counts.

- max_steps:

  Step cap per episode.

- n_tilings, bins, table_size:

  Tile-coder configuration.

- seed:

  Seed.

- make_kwargs:

  List passed to `gymnasium.make`.

## Value

A list with the env id, a summary tibble, and learning curves.

## Examples

``` r
if (FALSE) { # \dontrun{
lunar_setup("/usr/bin/python3")
differentiate_fa("CartPole-v1", n_train = 200)
} # }
```
