# Dotfiles

These are my personal dotfiles. They're not perfect, and they don't always work flawlessly, but when they do, they make my life easier. I use this repository to store configurations for my everyday tools, helping me maintain awareness of what goes into my setup. As a result, I feel that I work more efficiently and intentionally.

When facing a hard task and feeling stuck, managing my dotfiles acts as a productive form of "sharpening knives." Instead of getting distracted by TikTok or YouTube, I spend my time refining configurations, learning, and improving my skills. It keeps me engaged, productive, and constantly moving forward. At least, that's what I think now, though it's likely that I put too much pressure on myself to always spend my time productively. I'm still learning about myself.

## How to Use

My goal is to keep things simple, just make sure Python 3.11 or higher is installed. After that, all you need to do is clone the repo and run `python install.py`.

```bash
git clone https://github.com/mariocesar/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
python install.py
```

The command `python install.py` creates symlinks for all files in the repository, mirroring its structure in your home directory.

For example to see the installation "Plan" you can run:

```bash
python install.py --fake --noinput
```

For additional options, run: `python install.py --help`

```
usage: install.py [-h] [--noinput] [--force] [--fake]

Install dotfiles

options:
  -h, --help  show this help message and exit
  --noinput   Don't ask to confirm every action
  --force     Replace target files if they already exist
  --fake      Perform a dry-run without making actual changes
```
