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

# Path to your file
EQ_CSS="$HOME/.config/equibop/settings/quickCss.css"

ash-theme() {
    cat <<'EOT' > "$EQ_CSS"
@import url("https://raw.githubusercontent.com/orblazer/discord-nordic/master/nordic.vencord.css");

/*
 * Equibop QuickCSS - Ash Theme
 * Forces light text + dark surfaces even when Discord is in light mode.
 * Also normalises text variables for both light/dark so all fonts follow the palette.
 */

/* Nord palette fallbacks (used if the imported theme doesn't expose them) */
:root {
    --eq-n0:  #2e3440;
    --eq-n1:  #3b4252;
    --eq-n2:  #434c5e;
    --eq-n3:  #4c566a;
    --eq-n4:  #d8dee9;
    --eq-n5:  #e5e9f0;
    --eq-n6:  #eceff4;
    --eq-n8:  #88c0d0;
    --eq-n10: #5e81ac;
    --eq-n11: #bf616a;
    --eq-n13: #ebcb8b;
    --eq-n14: #a3be8c;
    --eq-n15: #b48ead;
}

/* Base text tokens for Ash (force light text on dark surfaces) */
html.theme-dark, .theme-dark, :root.theme-dark,
html.theme-light, .theme-light, :root.theme-light {
    --text-normal:              var(--eq-n6) !important;
    --text-muted:               var(--eq-n4) !important;
    --text-link:                var(--eq-n8) !important;
    --text-link-low-saturation: var(--eq-n8) !important;
    --header-primary:           var(--eq-n6) !important;
    --header-secondary:         var(--eq-n5) !important;
    --channels-default:         var(--eq-n5) !important; /* brighter for list contrast */
    --interactive-normal:       var(--eq-n5) !important;
    --interactive-hover:        var(--eq-n6) !important;
    --interactive-active:       var(--eq-n6) !important;
    --interactive-muted:        var(--eq-n4) !important; /* avoid blending into bg */
    --text-positive:            var(--eq-n14) !important;
    --text-warning:             var(--eq-n13) !important;
    --text-danger:              var(--eq-n11) !important;
    --text-brand:               var(--eq-n8) !important;
    --status-danger:            var(--eq-n11) !important;
    --status-warning:           var(--eq-n13) !important;
    --focus-primary:            var(--eq-n8) !important;
    --link-muted:               var(--eq-n8) !important;

    /* Some components rely on primary tokens; brighten them for readability */
    --primary-500: var(--eq-n6) !important;
    --primary-600: var(--eq-n5) !important;
    --primary-630: var(--eq-n5) !important;
    --primary-660: var(--eq-n5) !important;
    --primary-700: var(--eq-n4) !important;
    --primary-800: var(--eq-n4) !important;
}

/* ASH OVERRIDE: make light mode use dark surfaces + light text */
html.theme-light, .theme-light, :root.theme-light {
    color-scheme: dark;
    --neutral-1:  var(--eq-n0) !important;
    --neutral-2:  var(--eq-n1) !important;
    --neutral-4:  var(--eq-n2) !important;

    --background-primary:        var(--eq-n0) !important;
    --background-secondary:      var(--eq-n1) !important;
    --background-tertiary:       var(--eq-n2) !important;
    --background-floating:       var(--eq-n1) !important;
    --background-accent:         var(--eq-n3) !important;
    --bg-base-primary:           var(--eq-n0) !important;
    --channeltextarea-background: var(--eq-n2) !important;
    --input-background:           var(--eq-n2) !important;
}

/* Catch components that bypass tokens (ensures every font flips) */
:where(.theme-dark, .theme-light) :is(body, p, span, div, button, input, textarea, select, label) {
    color: var(--text-normal) !important;
}

:where(.theme-dark, .theme-light) a {
    color: var(--text-link) !important;
}

/* Discord uses `--text-default` on some headings; sync it to our normal token */
:where(.theme-dark, .theme-light) {
    --text-default: var(--text-normal) !important;
}

/* Explicitly catch defaultColor_* headings (seen in title/name blocks) */
:where(.theme-dark, .theme-light) :is(h1, h2, h3, h4, h5, h6, .defaultColor__5345c, .defaultColor__4bd52) {
    color: var(--text-normal) !important;
}

:where(.theme-dark, .theme-light) :is(input, textarea, select) {
    background-color: var(--input-background, var(--background-tertiary)) !important;
    color: var(--text-normal) !important;
}

:where(.theme-dark, .theme-light) ::placeholder {
    color: var(--text-muted) !important;
}
EOT
    touch "$EQ_CSS"
    echo "Switched to Ash Theme."
}

light-theme() {
    cat <<'EOT' > "$EQ_CSS"
@import url("https://raw.githubusercontent.com/orblazer/discord-nordic/master/nordic.vencord.css");

/*
 * Equibop QuickCSS - Nordic Light/Dark
 * Normalises text variables for both modes so every font updates correctly.
 */

:root {
    --eq-n0:  #2e3440;
    --eq-n1:  #3b4252;
    --eq-n2:  #434c5e;
    --eq-n3:  #4c566a;
    --eq-n4:  #d8dee9;
    --eq-n5:  #e5e9f0;
    --eq-n6:  #eceff4;
    --eq-n8:  #88c0d0;
    --eq-n10: #5e81ac;
    --eq-n11: #bf616a;
    --eq-n13: #ebcb8b;
    --eq-n14: #a3be8c;
    --eq-n15: #b48ead;
}

/* Dark mode text tokens */
html.theme-dark, .theme-dark, :root.theme-dark {
    --text-normal:              var(--eq-n6) !important;
    --text-muted:               var(--eq-n4) !important;
    --text-link:                var(--eq-n8) !important;
    --text-link-low-saturation: var(--eq-n8) !important;
    --header-primary:           var(--eq-n6) !important;
    --header-secondary:         var(--eq-n5) !important;
    --channels-default:         var(--eq-n5) !important;
    --interactive-normal:       var(--eq-n5) !important;
    --interactive-hover:        var(--eq-n6) !important;
    --interactive-active:       var(--eq-n6) !important;
    --interactive-muted:        var(--eq-n4) !important;
    --text-positive:            var(--eq-n14) !important;
    --text-warning:             var(--eq-n13) !important;
    --text-danger:              var(--eq-n11) !important;
    --text-brand:               var(--eq-n8) !important;
    --status-danger:            var(--eq-n11) !important;
    --status-warning:           var(--eq-n13) !important;
    --focus-primary:            var(--eq-n8) !important;
    --link-muted:               var(--eq-n8) !important;

    --primary-500: var(--eq-n6) !important;
    --primary-600: var(--eq-n5) !important;
    --primary-630: var(--eq-n5) !important;
    --primary-660: var(--eq-n5) !important;
    --primary-700: var(--eq-n4) !important;
    --primary-800: var(--eq-n4) !important;
}

/* Light mode text tokens */
html.theme-light, .theme-light, :root.theme-light {
    color-scheme: light;
    --text-normal:              var(--eq-n0) !important;
    --text-muted:               var(--eq-n3) !important;
    --text-link:                var(--eq-n10) !important;
    --text-link-low-saturation: var(--eq-n10) !important;
    --header-primary:           var(--eq-n0) !important;
    --header-secondary:         var(--eq-n2) !important;
    --channels-default:         var(--eq-n2) !important;
    --interactive-normal:       var(--eq-n2) !important;
    --interactive-hover:        var(--eq-n0) !important;
    --interactive-active:       var(--eq-n0) !important;
    --interactive-muted:        var(--eq-n4) !important;
    --text-positive:            var(--eq-n14) !important;
    --text-warning:             var(--eq-n13) !important;
    --text-danger:              var(--eq-n11) !important;
    --text-brand:               var(--eq-n10) !important;
    --status-danger:            var(--eq-n11) !important;
    --status-warning:           var(--eq-n13) !important;
    --focus-primary:            var(--eq-n10) !important;
    --link-muted:               var(--eq-n10) !important;

    --primary-500: var(--eq-n2) !important;
    --primary-600: var(--eq-n2) !important;
    --primary-630: var(--eq-n2) !important;
    --primary-660: var(--eq-n2) !important;
    --primary-700: var(--eq-n0) !important;
    --primary-800: var(--eq-n0) !important;
}

/* Element-level fallback so every font switches */
:where(.theme-dark, .theme-light) :is(body, p, span, div, button, input, textarea, select, label) {
    color: var(--text-normal) !important;
}

:where(.theme-dark, .theme-light) a {
    color: var(--text-link) !important;
}

/* Discord uses `--text-default` on some headings; sync it to our normal token */
:where(.theme-dark, .theme-light) {
    --text-default: var(--text-normal) !important;
}

/* Explicitly catch defaultColor_* headings (seen in title/name blocks) */
:where(.theme-dark, .theme-light) :is(h1, h2, h3, h4, h5, h6, .defaultColor__5345c, .defaultColor__4bd52) {
    color: var(--text-normal) !important;
}

:where(.theme-dark, .theme-light) :is(input, textarea, select) {
    background-color: var(--input-background, var(--background-tertiary)) !important;
    color: var(--text-normal) !important;
}

:where(.theme-dark, .theme-light) ::placeholder {
    color: var(--text-muted) !important;
}
EOT
    touch "$EQ_CSS"
    echo "Switched to Light Theme."
}
alias mcsr-offline="cd \"/home/borret/Documents/dev/MCSR Ranked Scraper\" && source .venv/bin/activate && python runner.py"
