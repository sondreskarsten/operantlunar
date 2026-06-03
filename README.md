# operantlunar

A tabular reinforcement-learning instrument that mechanistically differentiates **reward-maximizing control** (the law of effect) from **descriptive melioration** (the matching law). Native R, with an optional Python **LunarLander** environment via `reticulate` and a bundled **Shiny** app. Built to develop, build, and deploy from RStudio.

The thesis: a single learning skeleton (binned featurizer, value/preference table, rollouts) drives every environment. Only the **update rule** changes. A rule that bootstraps future value and selects greedily *maximizes*; a myopic linear-operator preference with probability-matching selection *meliorates*. The operant battery isolates the contexts where the two diverge.

## Install

```r
# from a local clone
R CMD INSTALL operantlunar
# or in R
devtools::install_github("sondreskarsten/operantlunar")
```

In RStudio: open the project and use the **Build** pane (Install, Check, Document via roxygen2).

## The differentiation, in one place

```r
library(operantlunar)

a <- td_agent()           # Q-learning: bootstrap + epsilon-greedy  -> maximizes
b <- melioration_agent()  # gradient-bandit preference, prob matching -> meliorates
```

Both expose `select`, `update`, `greedy`, `action_dist`. The skeleton (`make_table`, `run_episode`, `run_training`, `evaluate_policy`) is agent-agnostic. Actions are 1-based; the table is an environment mapping character state keys to numeric rows.

## Operant lever battery

| Lever | Function | What it isolates |
|---|---|---|
| Matching positive control | `fit_generalized_matching()` | both rules reproduce matching on concurrent VI |
| Melioration trap | `melioration_trap_experiment()` | the temporal-credit axis: optimum ≠ matching point |
| Schedule family | `schedule_matching_table()` | VI grades, VR goes exclusive |
| Extinction | `extinction_experiment()` | resistance to extinction by acquisition schedule |
| Whole battery | `operant_battery()` | all three |

Headline results (validated against the Python reference `sondreskarsten/operant-lunarlander`):

- **Matching law**: melioration fits `log(B1/B2) = a·log(R1/R2) + log b` with slope ≈ 0.97, bias ≈ 1.0.
- **Trap**: analytic optimum `x* = 0.4` (rate 0.48) vs matching point `x_m = 0.8` (rate 0.40). Melioration is caught at `x ≈ 1.0`; **expected-SARSA escapes**; Q-learning partially escapes.
- **Schedule family**: concurrent VI–VI graded (slope ≈ 1), concurrent VR–VR near-exclusive (slope undefined, masked by `mean_exclusivity`).
- **Extinction**: monotone ordering CRF > VR5 > VI10 in steps-to-extinction — an **acquired-value-magnitude** effect (anti-PREE for value learners; reported honestly, not hidden).

## LunarLander (Python) via reticulate

```r
lunar_setup()                 # declares gymnasium[box2d] via py_require(); provisioned automatically
# or reuse an interpreter that already has it:
lunar_setup("/usr/bin/python3")

res <- differentiate(n_train = 300, n_eval = 50)
plot_training(res)
```

`make_lunar()` wraps `gymnasium.make("LunarLander-v3")` behind the same `reset`/`step` interface as the native envs (R 1-based action → Gymnasium 0-based). The same R agents drive it, so the boundary is crossed per step; keep episode counts modest in interactive use.

The LunarLander performance comparison is **not** the headline result: the tabular gap sign-flips across bin counts, i.e. representation is the binding constraint, not the learning principle. The binding evidence lives in the operant battery above.

## Shiny app

```r
run_app()
```

Four tabs: melioration trap, schedule matching, extinction, and LunarLander. Deploy to Posit Connect / shinyapps.io with `rsconnect::deployApp(system.file("shiny", package = "operantlunar"))`; the LunarLander tab provisions `gymnasium[box2d]` on first run via `lunar_setup()`.

## Counterpoints tracked

- **Trap isolates the temporal-credit axis, not "RL beats matching" in general.** Relies on the payoff slopes making optimum ≠ matching point; with `ca = cb = 0` the two coincide and the contrast vanishes.
- **VI–VI positive control isolates the selection axis.** It shows both rules *can* match; it does not show melioration is wrong — only the trap does.
- **PREE is out of reach for value learners.** The extinction ordering is the opposite of the partial-reinforcement extinction effect; this is honest about what tabular value learning can and cannot reproduce, not a claim to model animal persistence.
- **LunarLander gap is a representation artifact.** The sign-flip across bins means any single-binning conclusion may be wrong; tile/coarse coding would be needed to make that comparison conclusive.

## License

MIT © 2026 Sondre Skarsten
