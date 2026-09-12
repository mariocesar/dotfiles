# Dotfiles

These are my personal dotfiles. They're not perfect, and they don't always work flawlessly, but when they do, they make my life easier. I use this repository to store configurations for my everyday tools, helping me maintain awareness of what goes into my setup. As a result, I feel that I work more efficiently and intentionally.

When facing a hard task and feeling stuck, managing my dotfiles acts as a productive form of "sharpening knives." Instead of getting distracted by TikTok or YouTube, I spend my time refining configurations, learning, and improving my skills. It keeps me engaged, productive, and constantly moving forward. At least, that's what I think now, though it's likely that I put too much pressure on myself to always spend my time productively. I'm still learning about myself.

## How to Use

My goal is to keep things simple. The installer is a standalone script that needs Python 3.10 or higher; no package installation is required. Clone the repo and run `install.py`.

```bash
git clone https://github.com/mariocesar/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
python3 install.py
```

Config is split into three buckets, and where a file sits decides which machine gets it:

```
common/   installed everywhere
linux/    Arch only
macos/    macOS only
```

Each mirrors your home directory, so `common/.config/nvim/init.lua` is symlinked to
`~/.config/nvim/init.lua`. `install.py` links `common/` plus the bucket for the OS it is
running on, then runs the `postinstall.d/` hooks those buckets carry. Anything outside a
bucket — this file, the installer itself — is never linked.

To see the plan without touching anything:

```bash
python3 install.py --fake
```

For additional options, run: `python3 install.py --help`

```
usage: install.py [-h] [--interactive] [--force] [--fake] [--prune]

Install dotfiles

options:
  -h, --help     show this help message and exit
  --interactive  Run with interactive prompts
  --force        Replace existing files, keeping the original as .bak
  --fake         Simulate actions without making changes
  --prune        Also remove links for config belonging to the other OS
```
