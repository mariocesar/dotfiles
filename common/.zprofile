# Login shells only: GDM spawns the session through one, so niri and dms.service inherit it.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# Unset, xcrun picks the newest SDK — betas included; this symlink tracks the installed CLT.
[ -d /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk ] && export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
