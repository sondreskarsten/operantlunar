import numpy as np, torch, random, time
import gymnasium as gym
from stable_baselines3 import DQN
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.evaluation import evaluate_policy
from stable_baselines3.common.callbacks import EvalCallback
torch.set_num_threads(1)
SEED=7
random.seed(SEED); np.random.seed(SEED); torch.manual_seed(SEED)
env=Monitor(gym.make("LunarLander-v3")); env.reset(seed=SEED)
eval_env=Monitor(gym.make("LunarLander-v3"))
cb=EvalCallback(eval_env, best_model_save_path="lunar/best", log_path="lunar/best",
                eval_freq=15000, n_eval_episodes=30, deterministic=True, verbose=0)
model=DQN("MlpPolicy", env, learning_rate=6.3e-4, batch_size=128, buffer_size=50000,
          learning_starts=0, gamma=0.99, target_update_interval=250, train_freq=4,
          gradient_steps=-1, exploration_fraction=0.12, exploration_final_eps=0.1,
          policy_kwargs=dict(net_arch=[128,128]), seed=SEED, verbose=0)
t0=time.time(); model.learn(total_timesteps=88000, callback=cb, progress_bar=False)
best=DQN.load("lunar/best/best_model")
m,s=evaluate_policy(best, Monitor(gym.make("LunarLander-v3")), n_eval_episodes=100, deterministic=True)
print(f"BEST_OF_RUN seed={SEED} train_time={time.time()-t0:.0f}s eval100_mean={m:.1f} eval100_std={s:.1f}")
