# -------------------------------------------------------------------
# Zsh Configuration for [borret]
# -------------------------------------------------------------------
setopt interactive_comments

# --- History Settings
# Larger history size for better autosuggestions
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# Don't save duplicate commands in a row
setopt HIST_IGNORE_DUPS

# --- FZF Integration
# Enables fzf keybindings (Ctrl+T, Ctrl+R, Alt+C) and fuzzy completion
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# --- Tab Completion System
# Initializes the Zsh completion system
autoload -U compinit
compinit

# --- Zsh Plugins (from Arch Repos)
# Load plugins in this order. Syntax highlighting should be last.

# 1. Autosuggestions (the "ghost text")
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# 2. Syntax Highlighting (real-time command checking)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Customize syntax highlighting colors for Nord light theme
# Valid commands: darker blue-gray instead of bright green
ZSH_HIGHLIGHT_STYLES[command]='fg=24'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=24'
ZSH_HIGHLIGHT_STYLES[function]='fg=24'
ZSH_HIGHLIGHT_STYLES[alias]='fg=24'
# Invalid commands: keep red but darker
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=124'

# --- Personal Settings & Aliases
# Prompt with current directory and prompt character
# Using Nord10 (darker blue-cyan) that fits Nord theme
PROMPT='%F{24}%~%f %# '

# Your preferred text editor
export EDITOR='nvim'

# Your aliases from .bashrc
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias screenfetch-nord="screenfetch -c \"4,0\""
alias sf="screenfetch -c \"4,0\""

# --- Final Sanity Check ---
# This removes the "zsh: insecure directories" warning if it appears
# You might not need it, but it doesn't hurt to have.
# zstyle ':completion:*' insecure 1
# comp
export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow --exclude .git . ~/Documents ~/Downloads ~"

# --- Copilot Command Suggest (Ctrl+Shift+I)
# Type a natural-language description, press Ctrl+Shift+I, and get a shell command.
# Uses GitHub Models API directly via curl for speed (~1-2s vs ~5-6s with the CLI).
_copilot_suggest() {
    local query="$BUFFER"
    [[ -z "$query" ]] && return
    zle -R "  Asking Copilot…"
    local t0=$EPOCHREALTIME
    local token
    token=$(gh auth token 2>/dev/null)
    [[ -z "$token" ]] && { zle -R "  ✗ Not logged in (gh auth login)"; zle reset-prompt; return; }
    local payload
    payload=$(jq -cn \
        --arg q "$query" \
        '{
            model: "gpt-4.1",
            messages: [
                {role: "system", content: "You are a shell command generator for zsh on Arch Linux. Reply with ONLY the command. No explanation, no markdown, no code fences."},
                {role: "user", content: $q}
            ]
        }')
    local cmd
    cmd=$(curl -s --max-time 15 \
        https://models.inference.ai.azure.com/chat/completions \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null | jq -r '.choices[0].message.content // empty')
    local elapsed=$(printf '%.1f' $(( EPOCHREALTIME - t0 )))
    if [[ -n "$cmd" ]]; then
        BUFFER="$cmd"
        CURSOR=${#BUFFER}
        zle -R "  ✓ ${elapsed}s"
    else
        zle -R "  ✗ No response (${elapsed}s)"
    fi
    zle reset-prompt
}
zle -N _copilot_suggest
bindkey '\e[105;6u' _copilot_suggest

# Discord QuickCSS helpers (assets shared with Super+Z theme_toggle)
# Desktop: Vesktop · Laptop: equibop · CSS: ~/.config/hypr/themes/quickcss-*.css
EQ_CSS="$HOME/.config/equibop/settings/quickCss.css"
VK_CSS="$HOME/.config/vesktop/settings/quickCss.css"
THEME_QUICKCSS_DIR="$HOME/.config/hypr/themes"

_write_discord_css() {
    local src=$1
    [[ -f "$src" ]] || return 1
    local wrote=0
    for dest in "$VK_CSS" "$EQ_CSS"; do
        if [[ -d "$(dirname "$dest")" ]]; then
            cp "$src" "$dest"
            touch "$dest"
            wrote=1
        fi
    done
    ((wrote)) || return 1
    return 0
}

ash-theme() {
    if _write_discord_css "${THEME_QUICKCSS_DIR}/quickcss-dark.css"; then
        echo "Switched to Ash Theme (dark)."
    else
        echo "Ash theme CSS missing at ${THEME_QUICKCSS_DIR}/quickcss-dark.css" >&2
        return 1
    fi
}

light-theme() {
    if _write_discord_css "${THEME_QUICKCSS_DIR}/quickcss-light.css"; then
        echo "Switched to Light Theme."
    else
        echo "Light theme CSS missing at ${THEME_QUICKCSS_DIR}/quickcss-light.css" >&2
        return 1
    fi
}
alias mcsr-offline="cd \"/home/borret/Documents/dev/MCSR Ranked Scraper\" && source .venv/bin/activate && python runner.py"

# Cloudflare tunnel helper: handles 'cloudflared arch-box' and manages the service
cloudflared() {
    if [[ "$1" == "arch-box" ]]; then
        if systemctl --user is-active --quiet cloudflared; then
            echo "Cloudflare Tunnel (arch-box) is already active as a systemd user service."
            systemctl --user status cloudflared --no-pager
        else
            echo "Starting Cloudflare Tunnel (arch-box) via systemd..."
            systemctl --user start cloudflared
            systemctl --user status cloudflared --no-pager
        fi
    else
        command cloudflared "$@"
    fi
}


# Added by Antigravity CLI installer
export PATH="/home/borret/.local/bin:$PATH"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
