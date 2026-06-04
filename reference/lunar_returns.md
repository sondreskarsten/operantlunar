# Load the bundled LunarLander evaluation returns

Returns the per-policy, per-terrain episode returns produced by
evaluating eight policies on LunarLander-v3 across 200 distinct terrains
(reset seeds). Policy seeds 0-3 are DQN policies: seeds 0 and 1 are
near-solved (true means of roughly 182 and 167), seeds 2 and 3 fail at
the same training budget (-1 and 6). Policy seeds 99-102 are PPO
policies trained to a common 620k-step budget by clean chunked resume:
all four solve (true means of roughly 243, 219, 238 and 242), so PPO's
training-seed lottery governs solve quality rather than solve-or-fail, a
milder lottery than DQN's. The two algorithms are trained to different
budgets, so the contrast is each algorithm's seed lottery at its own
near-solve budget, not a fixed-budget comparison. With `holdout = TRUE`
the returns of the verified solve (seed 99) on a disjoint terrain set
(reset seeds 201-400, true mean about 227) are loaded instead,
confirming the solve out of sample. The dataset is the substrate for
demonstrating that conclusions about a policy are invariant under the
protocol but not under ad hoc evaluation.

## Usage

``` r
lunar_returns(path = NULL, holdout = FALSE)
```

## Arguments

- path:

  Optional path to a returns CSV; defaults to the bundled dataset.

- holdout:

  If `TRUE`, load the held-out terrain returns instead.

## Value

A tibble with `policy_seed`, `terrain_seed`, `ret`.
