import numpy as np, torch, random
import gymnasium as gym
from stable_baselines3 import PPO
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.callbacks import EvalCallback
torch.set_num_threads(1)
SEED=0
random.seed(SEED); np.random.seed(SEED); torch.manual_seed(SEED)
env=Monitor(gym.make("LunarLander-v3")); env.reset(seed=SEED)
cb=EvalCallback(Monitor(gym.make("LunarLander-v3")), best_model_save_path="lunar/ppo_best",
                log_path="lunar/ppo_best", eval_freq=20000, n_eval_episodes=20, deterministic=True, verbose=0)
model=PPO("MlpPolicy", env, n_steps=1024, batch_size=64, n_epochs=4, gamma=0.999,
          gae_lambda=0.98, ent_coef=0.01, learning_rate=3e-4, policy_kwargs=dict(net_arch=[64,64]),
          seed=SEED, verbose=0)
model.learn(total_timesteps=900000, callback=cb, progress_bar=False)
