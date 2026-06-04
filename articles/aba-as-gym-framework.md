# ABA as a framework for reinforcement-learning problems

A reinforcement-learning problem is a reinforcement problem: an agent’s
behaviour is shaped by the reward contingencies of its environment.
Applied behaviour analysis is the science of analysing and changing
behaviour through reinforcement contingencies. So the ABA toolkit
(\[[`aba_toolkit()`](https://sondreskarsten.github.io/operantlunar/reference/aba_toolkit.md)\])
is an alternative analytic framework for the problems posed by a
Gymnasium environment: its instruments diagnose what maintains an
agent’s behaviour and change it by manipulating the contingency, rather
than by reading weights or gradients.

The bridge is the *contingency*. A Gymnasium environment exposes
`reset`/`step`;
\[[`contingency_env()`](https://sondreskarsten.github.io/operantlunar/reference/contingency_env.md)\]
wraps any environment whose `step` returns a named `channels` vector and
recomputes reward as the sum of the **active** channels. `set_active()`
is therefore the single lever every ABA instrument pulls.
\[[`as_channel_env()`](https://sondreskarsten.github.io/operantlunar/reference/as_channel_env.md)\]
turns an ordinary single-reward gym environment
(e.g. \[[`make_gym()`](https://sondreskarsten.github.io/operantlunar/reference/make_gym.md)\])
into a one-channel environment, so the same instruments apply to
off-the-shelf tasks.

## The mapping

``` r

aba_gym_mapping()
#> # A tibble: 5 × 4
#>   instrument                       rl_problem gym_mechanism diagnoses_or_changes
#>   <chr>                            <chr>      <chr>         <chr>               
#> 1 Functional analysis              What rewa… Reward-chann… Diagnoses which rei…
#> 2 Extinction                       How robus… Disable the … Diagnoses persisten…
#> 3 Differential reinforcement (DRA… Redirect … Extinguish o… Changes behaviour b…
#> 4 DRL                              Shape low… Reinforce th… Changes the tempora…
#> 5 Matching (phenomenon)            Character… Concurrent r… Diagnoses choice al…
```

## Functional analysis = reward-channel ablation

The applied question “what reinforcer maintains this behaviour?” becomes
the RL question “what reward component drives this policy?”.
\[[`gym_functional_analysis()`](https://sondreskarsten.github.io/operantlunar/reference/gym_functional_analysis.md)\]
trains the agent under each single-channel condition and a no-channel
play control, then identifies the maintaining channel as the condition
whose target response rate is elevated over control. It recovers a
planted function:

``` r

fa <- gym_functional_analysis(true_function = "escape")
fa$identified_channel
#> "escape"
plot_gym_functional_analysis(fa)
```

Verified result: the matching condition shows a target-response rate
near 0.98 while every other condition and the play control sit near
0.03, and `identified_channel == true_function` for all of attention,
escape, tangible, and goal. Ablating the channels isolates the one the
behaviour depends on.

## Extinction = withdraw the maintaining channel

Withholding the maintaining reinforcer should weaken the behaviour.
\[[`gym_extinction()`](https://sondreskarsten.github.io/operantlunar/reference/gym_extinction.md)\]
acquires a policy with the channel active, then withdraws it (channel
inactive) while continuing to train, probing retained behaviour by
evaluating with the channel restored. On the real `FrozenLake-v1` task:

``` r

builder <- function() as_channel_env(make_gym("FrozenLake-v1", is_slippery = FALSE), "goal")
gym_extinction(builder)
```

Verified result: the acquired greedy policy reaches the goal on 100% of
probes, then collapses to 0% within roughly ten unreinforced episodes.
Extinction under a deterministic greedy value learner is abrupt — once
the path’s value decays below the alternatives, the policy is abandoned
wholesale — which is itself an honest reading the framework surfaces.

## Differential reinforcement = reallocate the contingency

The function-based intervention “reinforce an alternative while the
problem behaviour is on extinction” becomes contingency-switching on a
navigation task.
\[[`gym_dra()`](https://sondreskarsten.github.io/operantlunar/reference/gym_dra.md)\]
reinforces a problem arm (baseline), then switches the active channel so
the problem arm is extinguished and an alternative arm is reinforced:

``` r

demo <- gym_dra()
plot_gym_dra(demo)
```

Verified result: the agent reaches the problem arm on ~0.84 of baseline
episodes and reallocates to the alternative arm at ~0.98 by the end of
treatment. The contingency engine that underlies DRA/FCT transfers
directly to a multi-state gym environment.

## What this is and is not

These instruments validate the ABA *logic* on the Gymnasium contract
with reinforcement-driven agents; they are not clinical procedures, and
functional analysis remains one scoped instrument rather than a
prerequisite. What the framework adds to an RL problem is a vocabulary
of contingency manipulations — ablate a channel to attribute a
behaviour, withdraw it to test persistence, switch it to redirect — that
read and change behaviour in the environment’s own terms.
