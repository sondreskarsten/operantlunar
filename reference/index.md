# Package index

## Learning skeleton

- [`make_table()`](https://sondreskarsten.github.io/operantlunar/reference/make_table.md)
  : Create a state-action value table
- [`table_get()`](https://sondreskarsten.github.io/operantlunar/reference/table_get.md)
  : Get a row from the table, defaulting to zeros
- [`run_episode()`](https://sondreskarsten.github.io/operantlunar/reference/run_episode.md)
  : Run a single episode
- [`run_training()`](https://sondreskarsten.github.io/operantlunar/reference/run_training.md)
  : Train an agent for several episodes
- [`evaluate_policy()`](https://sondreskarsten.github.io/operantlunar/reference/evaluate_policy.md)
  : Evaluate a fixed policy
- [`run_continuing()`](https://sondreskarsten.github.io/operantlunar/reference/run_continuing.md)
  : Run an agent on a continuing (non-episodic) environment

## Learning rules

- [`softmax()`](https://sondreskarsten.github.io/operantlunar/reference/softmax.md)
  : Softmax with inverse temperature
- [`td_agent()`](https://sondreskarsten.github.io/operantlunar/reference/td_agent.md)
  : Q-learning agent (law of effect with foresight)
- [`expected_sarsa_agent()`](https://sondreskarsten.github.io/operantlunar/reference/expected_sarsa_agent.md)
  : Expected-SARSA agent (on-policy bootstrap)
- [`boltzmann_td_agent()`](https://sondreskarsten.github.io/operantlunar/reference/boltzmann_td_agent.md)
  : Boltzmann Q-learning agent (softmax selection over Q)
- [`sarsa_agent()`](https://sondreskarsten.github.io/operantlunar/reference/sarsa_agent.md)
  : SARSA agent (on-policy bootstrap)
- [`double_q_agent()`](https://sondreskarsten.github.io/operantlunar/reference/double_q_agent.md)
  : Double Q-learning agent (de-biased maximization)
- [`actor_critic_agent()`](https://sondreskarsten.github.io/operantlunar/reference/actor_critic_agent.md)
  : Actor-critic agent (policy gradient with a TD critic)
- [`model_based_agent()`](https://sondreskarsten.github.io/operantlunar/reference/model_based_agent.md)
  : Model-based planning agent (goal-directed control)
- [`melioration_agent()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_agent.md)
  : Melioration agent (myopic linear-operator preference)
- [`melioration_rate_agent()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_rate_agent.md)
  : Rate-tracking melioration agent (Herrnstein-Vaughan)
- [`win_stay_lose_shift_agent()`](https://sondreskarsten.github.io/operantlunar/reference/win_stay_lose_shift_agent.md)
  : Win-stay-lose-shift agent (operant heuristic)
- [`bush_mosteller_step()`](https://sondreskarsten.github.io/operantlunar/reference/bush_mosteller_step.md)
  : One Bush-Mosteller probability-space update
- [`agent_registry()`](https://sondreskarsten.github.io/operantlunar/reference/agent_registry.md)
  : Agent registry
- [`make_agent()`](https://sondreskarsten.github.io/operantlunar/reference/make_agent.md)
  : Construct an agent by name
- [`agent_kind()`](https://sondreskarsten.github.io/operantlunar/reference/agent_kind.md)
  : Behavioral class of a rule

## Featurizers

- [`lunar_featurizer()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_featurizer.md)
  : LunarLander state featurizer
- [`interval_featurizer()`](https://sondreskarsten.github.io/operantlunar/reference/interval_featurizer.md)
  : Scalar (1-D) featurizer
- [`constant_featurizer()`](https://sondreskarsten.github.io/operantlunar/reference/constant_featurizer.md)
  : Constant single-state featurizer
- [`discrete_featurizer()`](https://sondreskarsten.github.io/operantlunar/reference/discrete_featurizer.md)
  : Discrete-observation featurizer
- [`make_bin_edges()`](https://sondreskarsten.github.io/operantlunar/reference/make_bin_edges.md)
  : Bin edges for the LunarLander observation

## Operant paradigms

- [`make_schedule()`](https://sondreskarsten.github.io/operantlunar/reference/make_schedule.md)
  : Build a schedule by name
- [`operant_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/operant_chamber.md)
  : Single-operandum operant chamber
- [`concurrent_schedule()`](https://sondreskarsten.github.io/operantlunar/reference/concurrent_schedule.md)
  : Concurrent two-operandum schedule
- [`concurrent_schedule_cod()`](https://sondreskarsten.github.io/operantlunar/reference/concurrent_schedule_cod.md)
  : Concurrent schedule with a changeover delay
- [`melioration_trap()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_trap.md)
  : Melioration trap environment
- [`prob_matching_task()`](https://sondreskarsten.github.io/operantlunar/reference/prob_matching_task.md)
  : Probability-matching task
- [`self_control_env()`](https://sondreskarsten.github.io/operantlunar/reference/self_control_env.md)
  : Self-control (delay-discounting) environment
- [`drl_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/drl_chamber.md)
  : Differential-reinforcement-of-low-rate chamber
- [`progressive_ratio()`](https://sondreskarsten.github.io/operantlunar/reference/progressive_ratio.md)
  : Progressive-ratio schedule
- [`risk_env()`](https://sondreskarsten.github.io/operantlunar/reference/risk_env.md)
  : Risk-sensitivity environment
- [`devaluation_env()`](https://sondreskarsten.github.io/operantlunar/reference/devaluation_env.md)
  : Reinforcer-devaluation environment

## Experiments

- [`melioration_trap_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_trap_experiment.md)
  : Melioration-trap experiment
- [`schedule_matching_table()`](https://sondreskarsten.github.io/operantlunar/reference/schedule_matching_table.md)
  : Matching slopes across schedule types
- [`fit_matching_general()`](https://sondreskarsten.github.io/operantlunar/reference/fit_matching_general.md)
  : Fit the generalized matching law for an arbitrary schedule pair
- [`extinction_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/extinction_experiment.md)
  : Extinction experiment
- [`operant_battery()`](https://sondreskarsten.github.io/operantlunar/reference/operant_battery.md)
  : Run the full operant battery
- [`prob_matching_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/prob_matching_experiment.md)
  : Probability-matching experiment
- [`self_control_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/self_control_experiment.md)
  : Self-control experiment
- [`drl_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/drl_experiment.md)
  : DRL experiment
- [`progressive_ratio_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/progressive_ratio_experiment.md)
  : Progressive-ratio experiment
- [`risk_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/risk_experiment.md)
  : Risk-sensitivity experiment
- [`devaluation_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/devaluation_experiment.md)
  : Reinforcer-devaluation experiment (habit vs goal-directed)
- [`changeover_delay_demo()`](https://sondreskarsten.github.io/operantlunar/reference/changeover_delay_demo.md)
  : Changeover-delay demonstration
- [`herrnstein_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/herrnstein_experiment.md)
  : Herrnstein single-alternative VI experiment

## Analysis

- [`value_of_policy()`](https://sondreskarsten.github.io/operantlunar/reference/value_of_policy.md)
  : Mean reward rate of a policy
- [`regret()`](https://sondreskarsten.github.io/operantlunar/reference/regret.md)
  : Regret against an optimal rate
- [`classify_rule()`](https://sondreskarsten.github.io/operantlunar/reference/classify_rule.md)
  : Classify behavior from a maximize score
- [`matching_sensitivity_bias()`](https://sondreskarsten.github.io/operantlunar/reference/matching_sensitivity_bias.md)
  : Generalized-matching sensitivity and bias
- [`fit_generalized_matching()`](https://sondreskarsten.github.io/operantlunar/reference/fit_generalized_matching.md)
  : Fit the generalized matching law on concurrent VI schedules
- [`fit_herrnstein_hyperbola()`](https://sondreskarsten.github.io/operantlunar/reference/fit_herrnstein_hyperbola.md)
  : Fit Herrnstein's single-alternative hyperbola
- [`fit_discounting()`](https://sondreskarsten.github.io/operantlunar/reference/fit_discounting.md)
  : Fit a delay-discounting function
- [`differentiation_matrix()`](https://sondreskarsten.github.io/operantlunar/reference/differentiation_matrix.md)
  : Differentiation matrix across rules and paradigms

## Function approximation

- [`gym_bounds()`](https://sondreskarsten.github.io/operantlunar/reference/gym_bounds.md)
  : Observation bounds for known environments
- [`tile_coder()`](https://sondreskarsten.github.io/operantlunar/reference/tile_coder.md)
  : Hashed tile coder
- [`linear_sarsa_agent()`](https://sondreskarsten.github.io/operantlunar/reference/linear_sarsa_agent.md)
  : Linear semi-gradient SARSA agent (tile features)
- [`linear_melioration_agent()`](https://sondreskarsten.github.io/operantlunar/reference/linear_melioration_agent.md)
  : Linear melioration agent (tile features)
- [`run_episode_linear()`](https://sondreskarsten.github.io/operantlunar/reference/run_episode_linear.md)
  : Run one episode with a linear agent
- [`run_training_linear()`](https://sondreskarsten.github.io/operantlunar/reference/run_training_linear.md)
  : Train a linear agent over episodes
- [`evaluate_policy_linear()`](https://sondreskarsten.github.io/operantlunar/reference/evaluate_policy_linear.md)
  : Evaluate a linear agent's policy
- [`differentiate_fa()`](https://sondreskarsten.github.io/operantlunar/reference/differentiate_fa.md)
  : Differentiate rules under linear function approximation

## Gymnasium

- [`lunar_setup()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_setup.md)
  : Configure the Python environment for LunarLander
- [`make_lunar()`](https://sondreskarsten.github.io/operantlunar/reference/make_lunar.md)
  : LunarLander-v3 environment adapter
- [`make_gym()`](https://sondreskarsten.github.io/operantlunar/reference/make_gym.md)
  : Generic Gymnasium environment adapter
- [`collect_states()`](https://sondreskarsten.github.io/operantlunar/reference/collect_states.md)
  : Collect states from random rollouts
- [`policy_divergence()`](https://sondreskarsten.github.io/operantlunar/reference/policy_divergence.md)
  : Total-variation policy divergence between two agents
- [`differentiate()`](https://sondreskarsten.github.io/operantlunar/reference/differentiate.md)
  : Differentiate maximizing TD from melioration on LunarLander
- [`differentiate_gym()`](https://sondreskarsten.github.io/operantlunar/reference/differentiate_gym.md)
  : Differentiate rules on a tabular Gymnasium environment

## Methodological protocol

- [`stability_reached()`](https://sondreskarsten.github.io/operantlunar/reference/stability_reached.md)
  : Steady-state stability of a per-condition rate series
- [`criterion_line_verdict()`](https://sondreskarsten.github.io/operantlunar/reference/criterion_line_verdict.md)
  : Criterion-line functional-analysis verdict (Hagopian et al., 1997)
- [`fa_stochastic_env()`](https://sondreskarsten.github.io/operantlunar/reference/fa_stochastic_env.md)
  : Stochastic functional-analysis channel environment
- [`fa_subject()`](https://sondreskarsten.github.io/operantlunar/reference/fa_subject.md)
  : One functional-analysis subject (multielement, trained to steady
  state)
- [`functional_analysis_replicated()`](https://sondreskarsten.github.io/operantlunar/reference/functional_analysis_replicated.md)
  : Replicated functional analysis to a reliability conclusion (no
  pooling)
- [`adhoc_fa()`](https://sondreskarsten.github.io/operantlunar/reference/adhoc_fa.md)
  : Ad hoc functional analysis (the undisciplined pipeline)
- [`convergence_demo()`](https://sondreskarsten.github.io/operantlunar/reference/convergence_demo.md)
  : Two-pipelines convergence demonstration
- [`reversal_probe()`](https://sondreskarsten.github.io/operantlunar/reference/reversal_probe.md)
  : Contingency-sensitivity (reversal) probe
- [`env_vs_agent_demo()`](https://sondreskarsten.github.io/operantlunar/reference/env_vs_agent_demo.md)
  : Apparatus (env_seed) versus subject (agent_seed) demonstration
- [`procedural_gridworld()`](https://sondreskarsten.github.io/operantlunar/reference/procedural_gridworld.md)
  : Procedural-layout gridworld (env_seed sets the apparatus)
- [`fa_subject_gridworld()`](https://sondreskarsten.github.io/operantlunar/reference/fa_subject_gridworld.md)
  : One functional-analysis subject on the procedural gridworld
- [`functional_analysis_replicated_gridworld()`](https://sondreskarsten.github.io/operantlunar/reference/functional_analysis_replicated_gridworld.md)
  : Replicated gridworld functional analysis to a reliability conclusion
- [`convergence_demo_gridworld()`](https://sondreskarsten.github.io/operantlunar/reference/convergence_demo_gridworld.md)
  : Two-pipelines convergence demonstration on the procedural gridworld

## LunarLander value-add

- [`lunar_returns()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_returns.md)
  : Load the bundled LunarLander evaluation returns
- [`lunar_steady_state_return()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_steady_state_return.md)
  : Steady-state evaluation estimate for one policy
- [`lunar_adhoc_solved()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_adhoc_solved.md)
  : Ad hoc "is it solved?" verdict from a short evaluation
- [`lunar_protocol_solved()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_protocol_solved.md)
  : Protocol "is it solved?" verdict with quantified reliability
- [`lunar_solved_convergence()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_solved_convergence.md)
  : Convergence demonstration for the "is it solved?" conclusion
- [`lunar_best_policy_convergence()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_best_policy_convergence.md)
  : Convergence demonstration for the "which policy is best?" conclusion
- [`lunar_training_reliability()`](https://sondreskarsten.github.io/operantlunar/reference/lunar_training_reliability.md)
  : Training-seed reliability of the solved conclusion

## Plots

- [`plot_convergence()`](https://sondreskarsten.github.io/operantlunar/reference/plot_convergence.md)
  : Plot a two-pipelines convergence demonstration
- [`plot_cumulative_record()`](https://sondreskarsten.github.io/operantlunar/reference/plot_cumulative_record.md)
  : Plot a cumulative record
- [`plot_differentiation_matrix()`](https://sondreskarsten.github.io/operantlunar/reference/plot_differentiation_matrix.md)
  : Plot the differentiation matrix as a heatmap
- [`plot_discounting()`](https://sondreskarsten.github.io/operantlunar/reference/plot_discounting.md)
  : Plot a discounting fit
- [`plot_dra_fct()`](https://sondreskarsten.github.io/operantlunar/reference/plot_dra_fct.md)
  : Plot DRA / FCT reallocation
- [`plot_drl()`](https://sondreskarsten.github.io/operantlunar/reference/plot_drl.md)
  : Plot DRL results
- [`plot_extinction()`](https://sondreskarsten.github.io/operantlunar/reference/plot_extinction.md)
  : Plot the extinction result
- [`plot_fi_temporal()`](https://sondreskarsten.github.io/operantlunar/reference/plot_fi_temporal.md)
  : Plot fixed-interval temporal control
- [`plot_functional_analysis()`](https://sondreskarsten.github.io/operantlunar/reference/plot_functional_analysis.md)
  : Plot a functional analysis
- [`plot_gym_dra()`](https://sondreskarsten.github.io/operantlunar/reference/plot_gym_dra.md)
  : Plot a gym DRA reallocation
- [`plot_gym_functional_analysis()`](https://sondreskarsten.github.io/operantlunar/reference/plot_gym_functional_analysis.md)
  : Plot a gym functional analysis
- [`plot_gym_training()`](https://sondreskarsten.github.io/operantlunar/reference/plot_gym_training.md)
  : Plot linear-agent learning curves
- [`plot_herrnstein()`](https://sondreskarsten.github.io/operantlunar/reference/plot_herrnstein.md)
  : Plot a Herrnstein hyperbola fit
- [`plot_lunar_convergence()`](https://sondreskarsten.github.io/operantlunar/reference/plot_lunar_convergence.md)
  : Plot a LunarLander convergence demonstration
- [`plot_matching()`](https://sondreskarsten.github.io/operantlunar/reference/plot_matching.md)
  : Plot the generalized matching law fit
- [`plot_prob_matching()`](https://sondreskarsten.github.io/operantlunar/reference/plot_prob_matching.md)
  : Plot probability-matching results
- [`plot_progressive_ratio()`](https://sondreskarsten.github.io/operantlunar/reference/plot_progressive_ratio.md)
  : Plot progressive-ratio breakpoints
- [`plot_risk()`](https://sondreskarsten.github.io/operantlunar/reference/plot_risk.md)
  : Plot risk-sensitivity results
- [`plot_self_control()`](https://sondreskarsten.github.io/operantlunar/reference/plot_self_control.md)
  : Plot self-control results
- [`plot_training()`](https://sondreskarsten.github.io/operantlunar/reference/plot_training.md)
  : Plot LunarLander training returns
- [`plot_trap()`](https://sondreskarsten.github.io/operantlunar/reference/plot_trap.md)
  : Plot the melioration-trap result

## Operant-conditioning primer

- [`operant_glossary()`](https://sondreskarsten.github.io/operantlunar/reference/operant_glossary.md)
  : Operant-conditioning glossary
- [`operant_bibliography()`](https://sondreskarsten.github.io/operantlunar/reference/operant_bibliography.md)
  : Operant-conditioning bibliography

## ABA toolkit and phenomena

- [`aba_toolkit()`](https://sondreskarsten.github.io/operantlunar/reference/aba_toolkit.md)
  : ABA toolkit: validated function-based instruments
- [`basic_phenomena()`](https://sondreskarsten.github.io/operantlunar/reference/basic_phenomena.md)
  : Basic behavioural phenomena (candidate-instrument pipeline)
- [`fa_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/fa_chamber.md)
  : Functional-analysis chamber
- [`functional_analysis()`](https://sondreskarsten.github.io/operantlunar/reference/functional_analysis.md)
  : Functional analysis: identify a maintaining function
- [`dra_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/dra_chamber.md)
  : Differential-reinforcement (DRA/FCT) chamber
- [`dra_fct_demo()`](https://sondreskarsten.github.io/operantlunar/reference/dra_fct_demo.md)
  : DRA / FCT reallocation demonstration
- [`fi_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/fi_chamber.md)
  : Fixed-interval chamber with an elapsed-time observation
- [`cumulative_record()`](https://sondreskarsten.github.io/operantlunar/reference/cumulative_record.md)
  : Build a cumulative record
- [`schedule_record_demo()`](https://sondreskarsten.github.io/operantlunar/reference/schedule_record_demo.md)
  : Cumulative record of an agent on a single-operandum schedule
- [`fi_temporal_demo()`](https://sondreskarsten.github.io/operantlunar/reference/fi_temporal_demo.md)
  : Fixed-interval temporal-control demonstration

## ABA-to-gym mapping

- [`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md)
  : Contingency wrapper for any reinforcement environment
- [`as_channel_env()`](https://sondreskarsten.github.io/operantlunar/reference/as_channel_env.md)
  : Expose a single-reward environment as a one-channel environment
- [`fa_channel_env()`](https://sondreskarsten.github.io/operantlunar/reference/fa_channel_env.md)
  : Functional-analysis channel environment
- [`gridworld_env()`](https://sondreskarsten.github.io/operantlunar/reference/gridworld_env.md)
  : Composite-reward gridworld (Gymnasium-style)
- [`gym_functional_analysis()`](https://sondreskarsten.github.io/operantlunar/reference/gym_functional_analysis.md)
  : Functional analysis on a Gymnasium-style environment
- [`gym_dra()`](https://sondreskarsten.github.io/operantlunar/reference/gym_dra.md)
  : Differential reinforcement (DRA) on a Gymnasium-style gridworld
- [`gym_extinction()`](https://sondreskarsten.github.io/operantlunar/reference/gym_extinction.md)
  : Extinction on a Gymnasium environment
- [`aba_gym_mapping()`](https://sondreskarsten.github.io/operantlunar/reference/aba_gym_mapping.md)
  : ABA-to-gym mapping

## Schedules and helpers

- [`sched_FR()`](https://sondreskarsten.github.io/operantlunar/reference/schedules_family.md)
  [`sched_VR()`](https://sondreskarsten.github.io/operantlunar/reference/schedules_family.md)
  [`sched_FI()`](https://sondreskarsten.github.io/operantlunar/reference/schedules_family.md)
  [`sched_VI()`](https://sondreskarsten.github.io/operantlunar/reference/schedules_family.md)
  : Reinforcement schedule primitives
- [`concurrent_vi()`](https://sondreskarsten.github.io/operantlunar/reference/concurrent_vi.md)
  : Concurrent variable-interval environment
- [`run_matching()`](https://sondreskarsten.github.io/operantlunar/reference/run_matching.md)
  : Run a melioration agent on a concurrent VI schedule
- [`lunar_low`](https://sondreskarsten.github.io/operantlunar/reference/lunar_low.md)
  [`lunar_high`](https://sondreskarsten.github.io/operantlunar/reference/lunar_low.md)
  : LunarLander observation bounds

## App

- [`run_app()`](https://sondreskarsten.github.io/operantlunar/reference/run_app.md)
  : Launch the bundled Shiny app
