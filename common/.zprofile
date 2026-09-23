# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/mariocesar/.docker/bin"
# End of Docker Desktop section.

# Login shells only: GDM spawns the session through one, so niri and dms.service inherit it.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
# llm defaults to ~/Library/Application Support on macOS; one path lets common/ carry its config
export LLM_USER_PATH="$HOME/.config/io.datasette.llm"

# Unset, xcrun picks the newest SDK — betas included; this symlink tracks the installed CLT.
[ -d /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk ] && export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk

# Session-wide Android Studio
if [ -d "$HOME/Android/Sdk" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
elif [ -d "$HOME/Library/Android/sdk" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
fi

[ -n "${ANDROID_HOME:-}" ] && \
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# flutter looks for `google-chrome`
[ -x /usr/bin/google-chrome-stable ] && export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable
