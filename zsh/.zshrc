# uncomment to test diagnostics
#zmodload zsh/zprof

# =============================================================================
# .zshrc — Lean Zsh config with git goodies, no framework bloat
# =============================================================================
# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------
if [[ $(uname -m) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # Share history across sessions
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE      # Prefix with space to skip history
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY     # Write immediately, not on exit

# -----------------------------------------------------------------------------
# General Options
# -----------------------------------------------------------------------------
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_MINUS

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------
ZSH_DISABLE_COMPFIX="true"  # Skip slow compaudit security checks (safe on macOS/Homebrew)

autoload -Uz compinit

# Rebuild compdump only if missing or different day-of-year (once/day max)
local dumpfile="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -s "$dumpfile" ]] || [[ $(date +'%j') != $(stat -f '%Sm' -t '%j' "$dumpfile" 2>/dev/null) ]]; then
  compinit
else
  compinit -C   # Skip checks, just load existing dump
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# -----------------------------------------------------------------------------
# Git Aliases & Functions
# -----------------------------------------------------------------------------
function gcf() { git commit --fixup="$1"; }

function gwip() {
  git add -A
  git rm $(git ls-files --deleted) 2>/dev/null
  git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}

function gunwip() {
  git rev-parse --verify HEAD | grep -q -- "--wip--" && git reset HEAD~1
}

function git_main_branch() {
  git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
    | sed 's@^refs/remotes/origin/@@' \
    || echo main
}

function git_current_branch() {
  local ref
  ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gcmsg='git commit --message'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout "$(git_main_branch)"'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gm='git merge'
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'
alias gpf='git push --force-with-lease --force-if-includes'   # safer version only
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gr='git remote'
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grs='git restore'
alias grss='git restore --staged'
alias gsh='git show'
alias gss='git status --short'
alias gst='git status'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsw='git switch'
alias gswc='git switch --create'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'

# work exclusive
alias ggrd="git reset --hard origin/develop"
alias ggpush='git push origin "$(git_current_branch)"'
alias ggpull='git pull origin "$(git_current_branch)"'
alias ggundo!='git reset --soft HEAD~1'
alias ggundo='git reset --soft HEAD~'
alias greset='git fetch && git reset --hard @{u} && git clean -fd'
alias gundo='git reset --mixed HEAD~'
alias gundosoft='git reset --soft HEAD~'

# -----------------------------------------------------------------------------
# Modern CLI Tool Aliases
# -----------------------------------------------------------------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias la='eza -a --icons --group-directories-first'

alias cat='bat --paging=never'
alias catp='bat --plain --paging=never'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

alias rg='rg --smart-case'
alias cd='z'

# -----------------------------------------------------------------------------
# Company Secrets
# -----------------------------------------------------------------------------
[[ -f ~/.config/secrets/latimes.zsh ]] && source ~/.config/secrets/latimes.zsh

# -----------------------------------------------------------------------------
# Common Aliases
# -----------------------------------------------------------------------------
alias ws="webstorm -e"
alias zcfg="subl ~/.zshrc"
alias zsrc="source ~/.zshrc"
alias zpcfg="subl ~/.zprofile"
alias zpsrc="source ~/.zprofile"
alias reload='exec $SHELL -l'
alias speed_test='time zsh -i -c exit'
for i in {1..9}; do alias $i="cd +$i"; done
alias d='dirs -v'

# -----------------------------------------------------------------------------
# Tool Init
# -----------------------------------------------------------------------------
export PATH=/Applications/WebStorm.app/Contents/MacOS:$PATH

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline'

# mise
eval "$(mise activate zsh)"

# Zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Starship (last)
eval "$(starship init zsh)"

export PATH="$HOME/.local/bin:$PATH"

export ANTHROPIC_MODEL=opusplan

# zoxide (must be last)
eval "$(zoxide init zsh)"

# uncomment to test diagnostics
#zprof