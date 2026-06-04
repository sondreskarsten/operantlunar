import os, sys, time, numpy as np, torch, random
import gymnasium as gym
from stable_baselines3 import PPO
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.evaluation import evaluate_policy
from stable_baselines3.common.callbacks import BaseCallback
torch.set_num_threads(1)
SEED=int(sys.argv[1]); TARGET=int(sys.argv[2]); FULL=int(sys.argv[3])
mp=f"lunar/ppo/ppo_seed{SEED}"
random.seed(SEED); np.random.seed(SEED); torch.manual_seed(SEED)
env=Monitor(gym.make("LunarLander-v3")); env.reset(seed=SEED)
class StopAt(BaseCallback):
    def __init__(self,t): super().__init__(); self.t=t
    def _on_step(self): return self.model.num_timesteps < self.t
if os.path.exists(mp+".zip"):
    model=PPO.load(mp, env=env); first=False
else:
    model=PPO("MlpPolicy", env, n_steps=1024, batch_size=64, n_epochs=4, gamma=0.999,
              gae_lambda=0.98, ent_coef=0.01, learning_rate=3e-4, policy_kwargs=dict(net_arch=[64,64]),
              seed=SEED, verbose=0); first=True
t0=time.time()
model.learn(total_timesteps=FULL, reset_num_timesteps=first, callback=StopAt(TARGET), progress_bar=False)
dt=time.time()-t0
model.save(mp)
m,s=evaluate_policy(model, Monitor(gym.make("LunarLander-v3")), n_eval_episodes=20, deterministic=True)
print(f"PPO seed={SEED} num_timesteps={model.num_timesteps} chunk_time={dt:.0f}s eval50_mean={m:.1f} eval50_std={s:.1f}")
