# operantlunar 0.4.3

* README is now generated from `README.Rmd` and covers the full package: the maximization-vs-melioration core, the ABA-on-Gymnasium framings, and the methodological protocol with the LunarLander value-add, with a hero figure and live examples. A package-level help page (`?operantlunar`), a function-family navigation table, and pkgdown reference groups for the protocol and the LunarLander value-add improve discoverability. DESCRIPTION gains URL and BugReports.

# operantlunar 0.4.2

* A verified LunarLander-v3 solve is now bundled. A PPO policy (policy seed 99 in the returns) reaches a true mean of about 243 over 200 terrains, clearing the canonical 200 threshold with far lower variance than the DQN policies. The solve was reached by chunked resume, which PPO supports cleanly because it has no replay buffer, unlike the DQN warm-restart that degraded under resume. `lunar_training_reliability()` now identifies exactly one of five policies as solved, and the solved policy supplies a clear-winner case for `lunar_best_policy_convergence()` to complement the indistinguishable case. The protocol's separating power remains concentrated near the threshold: for a clearly solved policy the ad hoc and protocol verdicts agree, which is the correct behaviour.

# operantlunar 0.4.1

* New vignette "ABA as a methodological protocol for reinforcement learning" articulating the headline: the protocol makes behavioural conclusions about an agent invariant to researcher degrees of freedom, tying together the functional-analysis convergence demonstration and the LunarLander value-add.
* The Shiny app (`run_app()`) gains a "Protocol value-add (RDoF)" tab that stress-tests the "is it solved?" and "which policy is best?" conclusions on the bundled LunarLander returns, contrasting the budget-dependent ad hoc verdict with the invariant protocol verdict and its bootstrap confidence, alongside the training-seed reliability table. Python-free.

# operantlunar 0.4.0

## LunarLander: the protocol as a value-add on a real control task

* Applies the methodological protocol to LunarLander-v3, where the environment seed sets the terrain. Four DQN policies (training seeds 0-3) were trained with Stable-Baselines3; their per-terrain returns over 200 terrains are bundled and loaded by `lunar_returns()`. The functions reuse `stability_reached()` for a steady-state evaluation estimate (`lunar_steady_state_return()`), apply a frozen solved threshold (`lunar_protocol_solved()`), and show that conclusions are invariant under the protocol but not under ad hoc evaluation.
* `lunar_solved_convergence()`: a short evaluation declares the policy solved or not solved depending on the episode budget and terrain pool (at five episodes the verdict is a coin flip across pools), while the protocol reads a settled estimate near 174 and reports not solved with a bootstrap confidence near two percent. `lunar_best_policy_convergence()`: the ad hoc head-to-head winner of two near-identical policies flips with the evaluation while the protocol reports them indistinguishable, making concrete that the best policy can be an evaluation-sample artifact. `lunar_training_reliability()`: at a fixed budget two of four training seeds reach about 173 and two fail near zero, so a claim resting on one trained seed is not reproducible.
* Training scripts are in `data-raw/lunar/`. A verified solve (mean at least 200 over 100+ episodes) was not reached in the constrained build environment (single core, destructive warm-restart on resume); the bundled policies are near-solved (true means about 167 to 182), which makes the unreliability of ad hoc solved claims especially direct.

# operantlunar 0.3.0

## ABA as a methodological protocol

* The toolkit is reframed from a relabelling of reinforcement learning into a parameter-fixed methodological protocol that makes behavioural conclusions about an agent invariant to researcher degrees of freedom (step budget, seeds, run-collapse rule). The frozen decision rules are grounded in the applied-behaviour-analysis literature: steady-state reading takes the mean of the last stabilised sessions after a minimum exposure (McSweeney & Murphy, 2014), and differentiation uses the criterion-line rule (Hagopian et al., 1997; Fisher et al., 2021) — upper and lower criterion lines at the control mean plus or minus one standard deviation, a condition differentiated when points above minus points below is at least half the data points — replacing subjective visual analysis.
* `fa_stochastic_env()` adds within-condition stochasticity so replication across subjects is non-vacuous. `stability_reached()` is the endogenous steady-state stopping rule and `criterion_line_verdict()` the frozen quantitative decision. `fa_subject()` runs one multielement subject trained to steady state; `functional_analysis_replicated()` replicates subjects to a reliability conclusion without pooling response rates across subjects, keeping the analysis idiographic.
* `procedural_gridworld()` is a navigation substrate whose layout is fixed by `env_seed` (the apparatus, a setting variable) and distinct from the agent's seed (the subject); `fa_subject_gridworld()` runs functional analysis on it. Because navigation is slow to learn, under-training is a real source of unreliable conclusions.
* `convergence_demo()` and `convergence_demo_gridworld()` are the headline demonstration: an ad hoc pipeline with an arbitrary step and seed budget reaches a budget-dependent conclusion, while the protocol's steady-state stopping and replication return an invariant verdict with residual variability quantified. `reversal_probe()` tests contingency sensitivity by reversing the maintaining condition and checking that behaviour tracks; `env_vs_agent_demo()` separates apparatus from subject on the gridworld; `plot_convergence()` visualises the asymmetry.

# operantlunar 0.2.0

## Operant-conditioning primer

* The toolkit instruments are mapped to the Gymnasium reset/step contract so ABA serves as an alternative analytic framework for RL problems. `contingency_env()` gates reward channels (the single lever the instruments pull); `as_channel_env()` exposes any single-reward gym env as one channel. `gym_functional_analysis()` performs functional analysis as reward-channel ablation (recovers a planted maintaining channel); `gym_dra()` reallocates behaviour from a problem arm to an alternative on a multi-state gridworld; `gym_extinction()` withdraws the maintaining channel on the real `FrozenLake-v1` task and shows the acquired policy collapse. `aba_gym_mapping()` documents the framework, with the vignette "ABA as a framework for reinforcement-learning problems".
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
* The signature set is reframed as a validated ABA toolkit. `aba_toolkit()` lists function-based instruments organised around the core mechanism (reinforcement, the operant contingency); `basic_phenomena()` holds reproduced phenomena as a candidate-instrument pipeline. `fa_chamber()` / `functional_analysis()` / `plot_functional_analysis()` add functional analysis as a scoped assessment instrument that recovers a planted maintaining function (attention, escape, tangible, automatic) against a play control; it is not a prerequisite for the other tools.
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
