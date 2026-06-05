# operantlunar - LunarLander quickstart
#
# Loads the bundled, verified-solved PPO policy, runs one episode, prints the
# return, and writes a GIF of the landing so you can watch it. Native R drives
# the Gymnasium environment through reticulate.
#
# Python setup is handled automatically by reticulate's ephemeral environment
# (lunar_setup() + py_require below provision gymnasium[box2d], stable-baselines3
# and pillow on first use). To use an existing Python instead, replace lunar_setup()
# with lunar_setup("/path/to/python") whose interpreter already has those packages.
#
#   source(system.file("examples", "lunar_quickstart.R", package = "operantlunar"))

library(operantlunar)
library(reticulate)

Sys.setenv(SDL_VIDEODRIVER = "dummy", SDL_AUDIODRIVER = "dummy")

lunar_setup()
py_require(c("stable-baselines3", "pillow"))

model_path <- system.file("extdata", "ppo_seed0_solved.zip", package = "operantlunar")
out_gif <- file.path(getwd(), "lunar_solved.gif")

py_run_string(sprintf('
import gymnasium as gym
from stable_baselines3 import PPO
from PIL import Image
env = gym.make("LunarLander-v3", render_mode="rgb_array")
model = PPO.load(r"%s")
obs, _ = env.reset(seed=6)
frames, total, done = [], 0.0, False
while not done:
    frames.append(env.render())
    action, _ = model.predict(obs, deterministic=True)
    obs, reward, terminated, truncated, _ = env.step(int(action))
    total += reward
    done = terminated or truncated
print(f"episode return: {total:.1f}  (solved threshold is 200)")
sub = frames[::3]
imgs = [Image.fromarray(f).resize((300, 200)) for f in sub]
imgs[0].save(r"%s", save_all=True, append_images=imgs[1:], duration=60, loop=0, optimize=True)
print("saved GIF to:", r"%s")
', model_path, out_gif, out_gif, out_gif))

cat("Done. Open", out_gif, "to watch the solved policy land.\n")
