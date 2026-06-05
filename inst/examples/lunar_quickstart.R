# operantlunar - LunarLander quickstart
#
# Watches the bundled, verified-solved PPO policy actually fly. By default it
# opens a real-time window and plays several fresh episodes on random terrains;
# on a headless machine it falls back to writing a GIF of those same runs. Each
# episode is a genuine fresh rollout, not a replay.
#
#   source(system.file("examples", "lunar_quickstart.R", package = "operantlunar"))
#
# Python is provisioned on first use (gymnasium[box2d], stable-baselines3, pillow),
# or point lunar_setup("/path/to/python") at an interpreter that already has them.

library(operantlunar)
library(reticulate)

episodes   <- 3L     # number of fresh episodes to run
force_mode <- NULL   # NULL = live window if a display is present, else GIF.
                     # Set "human" to force live, "rgb_array" to force a GIF.

lunar_setup()
py_require(c("stable-baselines3", "pillow"))

model_path <- system.file("extdata", "ppo_seed0_solved.zip", package = "operantlunar")
out_gif    <- file.path(getwd(), "lunar_runs.gif")
mode_arg   <- if (is.null(force_mode)) "auto" else force_mode

py_run_string(sprintf('
import os, sys
force_mode = "%s"
n_ep = %d
model_path = r"%s"
out_gif = r"%s"

mode = force_mode
if mode == "auto":
    mode = "human" if (os.name == "nt" or sys.platform == "darwin" or os.environ.get("DISPLAY")) else "rgb_array"
if mode == "rgb_array":
    os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
    os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import gymnasium as gym
from stable_baselines3 import PPO

model = PPO.load(model_path)
env = gym.make("LunarLander-v3", render_mode=mode)
frames, returns = [], []
for ep in range(n_ep):
    obs, _ = env.reset()                 # fresh random terrain each episode
    done, total = False, 0.0
    while not done:
        if mode == "rgb_array":
            frames.append(env.render())
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, terminated, truncated, _ = env.step(int(action))
        total += reward
        done = terminated or truncated
    returns.append(total)
    print(f"episode {ep+1}: return {total:.1f}  (solved threshold is 200)")
env.close()

if mode == "rgb_array":
    from PIL import Image
    sub = frames[::3]
    imgs = [Image.fromarray(f).resize((300, 200)) for f in sub]
    imgs[0].save(out_gif, save_all=True, append_images=imgs[1:], duration=60, loop=0, optimize=True)
    print("no live display detected; saved a GIF of the runs to:", out_gif)
else:
    print(f"watched {n_ep} live landings")
', mode_arg, episodes, model_path, out_gif))

cat("Done.\n")
