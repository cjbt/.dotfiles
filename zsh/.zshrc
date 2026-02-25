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
setopt AUTO_CD                # cd by typing directory name
setopt CORRECT                # Suggest corrections for typos
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------
autoload -Uz compinit
# Only regenerate completion dump once a day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
bindkey -e                    # Emacs-style bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# -----------------------------------------------------------------------------
# Git Aliases
# -----------------------------------------------------------------------------
# Detect main branch name
function git_main_branch() {
  local branch
  for branch in main trunk master; do
    if git show-ref -q --verify "refs/heads/$branch" 2>/dev/null; then
      echo "$branch"
      return
    fi
  done
  echo "main"
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
alias gcn!='git commit --verbose --amend --no-edit'
alias gcm='git commit --message'
alias gcmsg='git commit --message'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gm='git merge'
alias gmom='git merge origin/$(git_current_branch)'
alias gp='git push'
alias gpf='git push --force-with-lease'
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
alias ggnore="git reset --hard $(git_main_branch)"

# Handy git functions
function gcf() { git commit --fixup="$1"; }
function gwip() {
  git add -A
  git rm $(git ls-files --deleted) 2>/dev/null
  git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}
function gunwip() {
  git rev-parse --verify HEAD | grep -q -- "--wip--" && git reset HEAD~1
}

# -----------------------------------------------------------------------------
# Modern CLI Tool Aliases
# -----------------------------------------------------------------------------
# eza (ls replacement)
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias la='eza -a --icons --group-directories-first'

# bat (cat replacement)
alias cat='bat --paging=never'
alias catp='bat --plain --paging=never'  # No line numbers/decorations

# Use bat as manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ripgrep
alias rg='rg --smart-case'

# -----------------------------------------------------------------------------
# Company Secrets (sourced from ~/.config/secrets/)
# -----------------------------------------------------------------------------
for _secrets_file in ~/.config/secrets/*.zsh(N); do
  source "$_secrets_file"
done
unset _secrets_file

# -----------------------------------------------------------------------------
# Common Aliases
# -----------------------------------------------------------------------------
alias ws="webstorm -e"
alias zcfg="subl ~/.zshrc"
alias zsrc="source ~/.zshrc"
alias zpcfg="subl ~/.zprofile"
alias zpsrc="source ~/.zprofile"

# -----------------------------------------------------------------------------
# Tool Init
# -----------------------------------------------------------------------------
# webstorm cli launcher
export PATH=/Applications/WebStorm.app/Contents/MacOS:$PATH

# fzf
source <(fzf --zsh)

# Use fd with fzf for better file finding
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height=40%
  --layout=reverse
  --border
  --info=inline
'

# zoxide (smart cd)
eval "$(zoxide init zsh)"
alias cd='z'

# mise (version manager)
eval "$(mise activate zsh)"

# Zsh plugins via Homebrew
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Starship prompt (must be last)
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"
