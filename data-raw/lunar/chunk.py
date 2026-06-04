import os, sys, time, numpy as np, torch, random
import gymnasium as gym
from stable_baselines3 import DQN
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.evaluation import evaluate_policy
from stable_baselines3.common.callbacks import BaseCallback
torch.set_num_threads(1)
SEED=int(sys.argv[1]); TARGET=int(sys.argv[2]); FULL=int(sys.argv[3]); ARCH=int(sys.argv[4]) if len(sys.argv)>4 else 128
mp=f"lunar/models/dqn_seed{SEED}"; bp=mp+"_buf.pkl"
random.seed(SEED); np.random.seed(SEED); torch.manual_seed(SEED)
env=Monitor(gym.make("LunarLander-v3")); env.reset(seed=SEED)
class StopAt(BaseCallback):
    def __init__(self,t): super().__init__(); self.t=t
    def _on_step(self): return self.model.num_timesteps < self.t
if os.path.exists(mp+".zip"):
    model=DQN.load(mp, env=env); model.load_replay_buffer(bp); first=False
else:
    model=DQN("MlpPolicy", env, learning_rate=6.3e-4, batch_size=128, buffer_size=50000,
              learning_starts=0, gamma=0.99, target_update_interval=250, train_freq=4,
              gradient_steps=-1, exploration_fraction=0.12, exploration_final_eps=0.1,
              policy_kwargs=dict(net_arch=[ARCH,ARCH]), seed=SEED, verbose=0); first=True
t0=time.time()
model.learn(total_timesteps=FULL, reset_num_timesteps=first, callback=StopAt(TARGET), progress_bar=False)
dt=time.time()-t0
model.save(mp); model.save_replay_buffer(bp)
ev=Monitor(gym.make("LunarLander-v3"))
m,s=evaluate_policy(model, ev, n_eval_episodes=100, deterministic=True)
print(f"RESULT seed={SEED} num_timesteps={model.num_timesteps} chunk_time={dt:.0f}s steps_per_s={model.num_timesteps/(dt if first else 1)/1 if first else -1:.0f} eval_mean={m:.1f} eval_std={s:.1f}")
