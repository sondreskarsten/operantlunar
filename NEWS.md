# operantlunar 0.2.0

## Operant-conditioning primer

* `operant_glossary()` and `operant_bibliography()` provide a verified beginner's
  glossary of operant-conditioning concepts and the bundled handbook corpus,
  with a companion "An operant-conditioning primer" vignette and an **Operant
  primer** dashboard tab.

## Behavioral signatures

* `behavioral_signatures()` maps each glossary phenomenon to the agent and
  paradigm that demonstrate it in the agents' own behaviour, with honest status
  flags for signatures a reward-driven, single-state agent cannot reproduce
  (VR-vs-VI rate, FR post-reinforcement pause, the molecular changeover-delay
  mechanism).
* `fi_chamber()` exposes elapsed time as the observation so a value agent brings
  responding under temporal control; `fi_temporal_demo()` summarises the
  resulting break-and-run.
* `cumulative_record()` / `schedule_record_demo()` build the canonical cumulative
  record; `plot_cumulative_record()` and `plot_fi_temporal()` plot the new views.
* A **Behavioral signatures** dashboard tab runs the demonstrating agent live per
  phenomenon and shows its glossary definition alongside an honest status.
* `behavioral_signatures()` now separates an applied-robust core (DRA/FCT, extinction, DRL, self-control) from basic-science phenomena (matching law, FI, schedule records), reflecting what replicates and is used in applied ABA. `dra_chamber()` / `dra_fct_demo()` add the differential-reinforcement (DRA/FCT) reallocation signature: with the problem response on extinction and an alternative reinforced, behaviour reallocates to the alternative, the contingency engine behind the most robustly replicated applied intervention.

## New learning rules

* `sarsa_agent()`, `double_q_agent()`, `actor_critic_agent()`, `model_based_agent()`,
  `win_stay_lose_shift_agent()`, and a rate-tracking `melioration_rate_agent()`
  (Herrnstein-Vaughan), alongside the existing Q-learning and gradient-bandit
  melioration.
* `agent_registry()`, `make_agent()`, and `agent_kind()` give every paradigm a
  uniform way to instantiate any rule and label it as maximizer, meliorator, or
  heuristic.

## New operant paradigms

* `prob_matching_task()` / `prob_matching_experiment()` — probability matching.
* `self_control_env()` / `self_control_experiment()` — delay discounting with an
  equalized trial length so the larger-later reward is normatively better.
* `drl_chamber()` / `drl_experiment()` — differential reinforcement of low rates,
  with the inter-response time exposed as the observation.
* `progressive_ratio()` / `progressive_ratio_experiment()` — breakpoints.
* `risk_env()` / `risk_experiment()` — variance sensitivity at matched means.
* `devaluation_env()` / `devaluation_experiment()` — habit vs goal-directed
  control via reinforcer devaluation.
* `concurrent_schedule_cod()` / `changeover_delay_demo()` — changeover delays.

## Analysis layer

* `fit_herrnstein_hyperbola()` and `herrnstein_experiment()`, `fit_discounting()`,
  `matching_sensitivity_bias()` (with optional bootstrap), `value_of_policy()`,
  `regret()`, `classify_rule()`.
* `differentiation_matrix()` — the capstone, scoring every rule on every paradigm
  along the maximize-vs-meliorate axis, with `plot_differentiation_matrix()`.

## Function approximation

* `tile_coder()` (hashed), `gym_bounds()`, `linear_sarsa_agent()`,
  `linear_melioration_agent()`, linear episode/training/evaluation runners, and
  `differentiate_fa()`.
* `make_gym()` is a generic Gymnasium adapter; `differentiate_gym()` runs tabular
  rules on discrete-observation environments such as FrozenLake.

## Plots

* `plot_prob_matching()`, `plot_self_control()`, `plot_drl()`,
  `plot_progressive_ratio()`, `plot_risk()`, `plot_discounting()`,
  `plot_herrnstein()`, `plot_gym_training()`.

# operantlunar 0.1.0

* Initial release: learning skeleton, Q-learning / expected-SARSA / gradient-bandit
  melioration, schedule family, melioration trap, extinction, generalized-matching
  fit, reticulate LunarLander bridge, and a Shiny app.
