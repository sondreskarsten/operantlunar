# An operant-conditioning primer

This primer orients a newcomer to the operant-conditioning vocabulary
that `operantlunar` is built on. Every definition below is drawn from
[`operant_glossary()`](https://sondreskarsten.github.io/operantlunar/reference/operant_glossary.md)
and was checked against the literature before entry; the sources are the
bundled handbook corpus plus the original papers, listed in
[`operant_bibliography()`](https://sondreskarsten.github.io/operantlunar/reference/operant_bibliography.md).

## The one idea

Operant conditioning studies how the **consequences** of a voluntary
behaviour change its future probability. Thorndike’s *law of effect*
(1898, 1911) stated the seed: responses followed by satisfaction are
stamped in, those followed by discomfort stamped out. Skinner (1938)
made it functional — replacing “satisfaction” with **reinforcement**
(anything that increases a behaviour) and “discomfort” with
**punishment** (anything that decreases it), each defined purely by its
effect. The unit of analysis is the **three-term contingency**: an
antecedent signals that a behaviour will produce a consequence.

The same logic is what reinforcement learning later formalised, which is
why this package can compare *reward maximisation* (the law of effect
taken to its optimum) against *melioration* (the rule behind the
matching law) using one learning skeleton and swapping only the update
rule.

## How the vocabulary maps onto this package

| Operant concept                         | In operantlunar                                                                                                                                                                                                              |
|:----------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Reinforcement schedule (FR/VR/FI/VI)    | [`make_schedule()`](https://sondreskarsten.github.io/operantlunar/reference/make_schedule.md), [`operant_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/operant_chamber.md)                             |
| Concurrent schedules / choice           | [`concurrent_schedule()`](https://sondreskarsten.github.io/operantlunar/reference/concurrent_schedule.md), [`schedule_matching_table()`](https://sondreskarsten.github.io/operantlunar/reference/schedule_matching_table.md) |
| Matching law                            | [`fit_matching_general()`](https://sondreskarsten.github.io/operantlunar/reference/fit_matching_general.md), [`melioration_agent()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_agent.md) selection |
| Melioration vs maximisation             | [`melioration_trap()`](https://sondreskarsten.github.io/operantlunar/reference/melioration_trap.md), [`differentiation_matrix()`](https://sondreskarsten.github.io/operantlunar/reference/differentiation_matrix.md)         |
| Extinction                              | [`extinction_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/extinction_experiment.md)                                                                                                                |
| Delay / self-control                    | [`self_control_env()`](https://sondreskarsten.github.io/operantlunar/reference/self_control_env.md), [`self_control_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/self_control_experiment.md)       |
| Differential reinforcement of low rates | [`drl_chamber()`](https://sondreskarsten.github.io/operantlunar/reference/drl_chamber.md), [`drl_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/drl_experiment.md)                                   |
| Reinforcer devaluation (habit vs goal)  | [`devaluation_experiment()`](https://sondreskarsten.github.io/operantlunar/reference/devaluation_experiment.md)                                                                                                              |

## Glossary

### Foundations

| Term                             | Definition                                                                                                                                                                                                                       | Primary source                |
|:---------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------|
| Law of effect                    | Responses followed by a satisfying state of affairs become more strongly connected to the situation and more likely to recur; those followed by discomfort are weakened. The seed of all consequence-based learning.             | Thorndike (1898, 1911)        |
| Operant conditioning             | Learning in which the future probability of a voluntary behaviour is changed by its consequences. Skinner’s functional reformulation of Thorndike’s law of effect, replacing subjective terms with reinforcement and punishment. | Skinner (1938)                |
| Respondent (Pavlovian) behaviour | Reflexive, involuntary behaviour elicited by an antecedent stimulus (e.g. salivation to food). Contrasted with operant behaviour; the domain of classical conditioning.                                                          | Pavlov (1927); Skinner (1938) |
| Operant behaviour                | Voluntary behaviour that operates on the environment and is controlled by its consequences, as opposed to being elicited by a prior stimulus.                                                                                    | Skinner (1938)                |
| Three-term contingency (A-B-C)   | The unit of operant analysis: an antecedent (discriminative stimulus) sets the occasion for a behaviour (response) that produces a consequence (reinforcer or punisher). Formalised by Skinner in the early 1950s.               | Skinner (1953)                |

### Consequences

| Term                               | Definition                                                                                                                                                              | Primary source |
|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------|
| Reinforcement                      | A consequence that increases the future frequency of the behaviour it follows. Defined functionally by its effect, not by whether it feels pleasant.                    | Skinner (1938) |
| Punishment                         | A consequence that decreases the future frequency of the behaviour it follows. Like reinforcement, defined by its effect on behaviour.                                  | Skinner (1938) |
| Positive reinforcement             | Adding a stimulus after a behaviour to increase that behaviour (e.g. food after a lever press). ‘Positive’ means a stimulus is presented, not that the outcome is good. | Skinner (1938) |
| Negative reinforcement             | Removing or postponing an aversive stimulus after a behaviour to increase that behaviour (e.g. a response that turns off a loud noise). Underlies escape and avoidance. | Skinner (1938) |
| Positive punishment                | Adding an aversive stimulus after a behaviour to decrease it (e.g. a reprimand following an action).                                                                    | Skinner (1938) |
| Negative punishment                | Removing a desirable stimulus after a behaviour to decrease it (e.g. loss of a privilege). Includes response cost and timeout.                                          | Skinner (1938) |
| Primary (unconditioned) reinforcer | A stimulus that is reinforcing without prior learning because of its biological significance (e.g. food, water).                                                        | Skinner (1938) |
| Conditioned (secondary) reinforcer | A previously neutral stimulus that acquires reinforcing power by being paired with an established reinforcer (e.g. a clicker, money).                                   | Skinner (1938) |
| Generalised reinforcer             | A conditioned reinforcer paired with many different reinforcers, so it is effective across motivational states (e.g. money, tokens, praise).                            | Skinner (1953) |

### Antecedents and stimulus control

| Term                          | Definition                                                                                                                                       | Primary source |
|:------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------|:---------------|
| Discriminative stimulus (S-D) | An antecedent stimulus in whose presence a response has been reinforced, so it comes to set the occasion for (signal) that response.             | Skinner (1938) |
| Stimulus control              | The degree to which an antecedent stimulus alters the probability of a behaviour, established through differential reinforcement across stimuli. | Skinner (1938) |

### Schedules

| Term                                    | Definition                                                                                                                                                  | Primary source           |
|:----------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------|
| Continuous reinforcement (CRF)          | A schedule in which every instance of the target response is reinforced. Produces fast acquisition but rapid extinction once reinforcement stops.           | Ferster & Skinner (1957) |
| Partial (intermittent) reinforcement    | Reinforcing only some instances of a response. Slower to acquire but more resistant to extinction than continuous reinforcement.                            | Ferster & Skinner (1957) |
| Fixed-ratio (FR)                        | Reinforcement after a fixed number of responses. Produces high response rates with a post-reinforcement pause after each reinforcer.                        | Ferster & Skinner (1957) |
| Variable-ratio (VR)                     | Reinforcement after a variable, unpredictable number of responses. Produces high, steady rates and strong resistance to extinction (the gambling schedule). | Ferster & Skinner (1957) |
| Fixed-interval (FI)                     | Reinforcement for the first response after a fixed time has elapsed. Produces a scalloped pattern: a pause then acceleration toward the interval’s end.     | Ferster & Skinner (1957) |
| Variable-interval (VI)                  | Reinforcement for the first response after a variable time has elapsed. Produces a steady, moderate rate; the workhorse schedule for studying choice.       | Ferster & Skinner (1957) |
| Partial-reinforcement extinction effect | Behaviour acquired under intermittent reinforcement extinguishes more slowly than behaviour acquired under continuous reinforcement.                        | Ferster & Skinner (1957) |

### Choice and dynamics

| Term                              | Definition                                                                                                                                                                                                                                                             | Primary source                              |
|:----------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------|
| Concurrent schedules              | Two or more reinforcement schedules available simultaneously on separate operanda, used to study how organisms allocate behaviour between alternatives.                                                                                                                | Herrnstein (1961)                           |
| Matching law                      | On concurrent variable-interval schedules the relative rate of responding to an alternative approximately equals the relative rate of reinforcement obtained from it: R1/(R1+R2) = r1/(r1+r2).                                                                         | Herrnstein (1961, 1970)                     |
| Undermatching, overmatching, bias | Systematic deviations from strict matching: undermatching (less extreme than predicted, often from frequent switching), overmatching (more extreme, often from a switching penalty), and constant bias toward one alternative.                                         | Baum (1974)                                 |
| Changeover delay (COD)            | A brief period after switching alternatives during which no reinforcer is delivered, used to suppress reinforcement of switching itself and reduce undermatching.                                                                                                      | Herrnstein (1961)                           |
| Melioration                       | A dynamic choice rule: allocate behaviour toward whichever alternative currently yields the higher local reinforcement rate. It produces matching on concurrent VI-VI but exclusive preference on concurrent VR-VR, and can be suboptimal.                             | Herrnstein & Vaughan (1980); Vaughan (1981) |
| Maximisation vs melioration       | Maximisation allocates behaviour to obtain the highest overall reinforcement rate; melioration tracks local rates. They coincide on many schedules but diverge when choosing an option changes its local return, where melioration can be caught short of the optimum. | Vaughan (1981); Herrnstein & Prelec (1991)  |

### Extinction and change

| Term                               | Definition                                                                                                                                                       | Primary source                           |
|:-----------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------|
| Extinction                         | Withholding the reinforcer that previously maintained a response, leading to a gradual decline in responding (often after a transient extinction burst).         | Skinner (1938); Ferster & Skinner (1957) |
| Shaping (successive approximation) | Building a new behaviour by reinforcing successively closer approximations to a target response.                                                                 | Skinner (1938)                           |
| Superstitious behaviour            | Behaviour strengthened by accidental (non-contingent) reinforcement that happens to follow it, despite no causal relation, as in Skinner’s pigeon demonstration. | Skinner (1948)                           |

### Function-based intervention

| Term                                                      | Definition                                                                                                                                                                                                     | Primary source                      |
|:----------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------|
| Functional analysis                                       | Systematically manipulating contingencies (attention, escape, tangible, alone) to identify the reinforcer maintaining a behaviour, so treatment can target that function.                                      | Fisher, Piazza & Roane 2021 (Ch 13) |
| Differential reinforcement of alternative behaviour (DRA) | Reinforcing an appropriate, functionally equivalent response while withholding reinforcement (extinction) for the problem response it replaces.                                                                | Fisher, Piazza & Roane 2021 (Ch 14) |
| Functional communication training (FCT)                   | A DRA procedure that teaches a communicative response to access the reinforcer maintaining problem behaviour; among the most robustly replicated applied interventions, with extinction a necessary component. | Carr & Durand (1985)                |

## Bibliography

The handbook corpus is held in GCS at
`gs://sondre_brreg_data/losore_schema_engine/aba_references/source_pdfs/`;
the primary sources are the original papers the definitions rest on.

| Key                         | Type     | Citation                                                                                                                                                                        |
|:----------------------------|:---------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| McSweeney & Murphy 2014     | handbook | McSweeney, F. K., & Murphy, E. S. (Eds.) (2014). The Wiley Blackwell Handbook of Operant and Classical Conditioning. Wiley-Blackwell.                                           |
| Bouton 2007                 | handbook | Bouton, M. E. (2007). Learning and Behavior: A Contemporary Synthesis. Sinauer Associates.                                                                                      |
| Fisher, Piazza & Roane 2021 | handbook | Fisher, W. W., Piazza, C. C., & Roane, H. S. (Eds.) (2021). Handbook of Applied Behavior Analysis (2nd ed.). Guilford Press.                                                    |
| Matson 2023                 | handbook | Matson, J. L. (Ed.) (2023). Handbook of Applied Behavior Analysis: Integrating Research into Practice. Springer.                                                                |
| Oxford ABA 2015             | handbook | Miltenberger, R. G., Miller, A., & Zerger, H. (2015). Applied Behavior Analysis. In The Oxford Handbook of Cognitive and Behavioral Therapies. Oxford University Press.         |
| Glimcher 2010               | handbook | Glimcher, P. W. (2010). Foundations of Neuroeconomic Analysis. Oxford University Press.                                                                                         |
| Thorndike 1911              | primary  | Thorndike, E. L. (1911). Animal Intelligence: Experimental Studies. Macmillan. (Law of effect; precursor in Thorndike, 1898.)                                                   |
| Skinner 1938                | primary  | Skinner, B. F. (1938). The Behavior of Organisms: An Experimental Analysis. Appleton-Century-Crofts.                                                                            |
| Skinner 1948                | primary  | Skinner, B. F. (1948). ‘Superstition’ in the pigeon. Journal of Experimental Psychology, 38, 168-172.                                                                           |
| Skinner 1953                | primary  | Skinner, B. F. (1953). Science and Human Behavior. Macmillan.                                                                                                                   |
| Ferster & Skinner 1957      | primary  | Ferster, C. B., & Skinner, B. F. (1957). Schedules of Reinforcement. Appleton-Century-Crofts.                                                                                   |
| Herrnstein 1961             | primary  | Herrnstein, R. J. (1961). Relative and absolute strength of response as a function of frequency of reinforcement. Journal of the Experimental Analysis of Behavior, 4, 267-272. |
| Herrnstein 1970             | primary  | Herrnstein, R. J. (1970). On the law of effect. Journal of the Experimental Analysis of Behavior, 13, 243-266.                                                                  |
| Baum 1974                   | primary  | Baum, W. M. (1974). On two types of deviation from the matching law: Bias and undermatching. Journal of the Experimental Analysis of Behavior, 22, 231-242.                     |
| Herrnstein & Vaughan 1980   | primary  | Herrnstein, R. J., & Vaughan, W. (1980). Melioration and behavioral allocation. In J. E. R. Staddon (Ed.), Limits to Action. Academic Press.                                    |
| Vaughan 1981                | primary  | Vaughan, W. (1981). Melioration, matching, and maximization. Journal of the Experimental Analysis of Behavior, 36, 141-149.                                                     |
| Carr & Durand 1985          | primary  | Carr, E. G., & Durand, V. M. (1985). Reducing behavior problems through functional communication training. Journal of Applied Behavior Analysis, 18, 111-126.                   |
