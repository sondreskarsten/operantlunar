import numpy as np, torch, csv, time
import gymnasium as gym
from stable_baselines3 import DQN
torch.set_num_threads(1)
SEEDS=[0,1,2,3]; N_TERRAINS=200
env=gym.make("LunarLander-v3")
rows=[]; t0=time.time()
for sd in SEEDS:
    model=DQN.load(f"lunar/models/dqn_seed{sd}")
    rets=[]
    for terr in range(1, N_TERRAINS+1):
        obs,_=env.reset(seed=terr); done=False; tot=0.0
        while not done:
            a,_=model.predict(obs, deterministic=True)
            obs,r,term,trunc,_=env.step(int(a)); tot+=r; done=term or trunc
        rets.append(tot); rows.append((sd, terr, tot))
    rets=np.array(rets)
    print(f"policy seed={sd}: mean={rets.mean():.1f} std={rets.std():.1f} solved(mean>=200)={rets.mean()>=200}")
with open("lunar/returns.csv","w",newline="") as f:
    w=csv.writer(f); w.writerow(["policy_seed","terrain_seed","ret"]); w.writerows(rows)
print(f"wrote {len(rows)} rows in {time.time()-t0:.0f}s")
