# dotfiles

Portable dev configs managed by [GNU Stow](https://www.gnu.org/software/stow/). Company-specific stuff (signing keys, emails, tokens) lives outside this repo and is managed by Ansible.

## Setup

```sh
git clone <this-repo> ~/.dotfiles
~/.dotfiles/install.sh
```

Script handles installing Homebrew and Stow if missing.

## Packages

| Package | What |
|---|---|
| zsh | shell config, aliases, tool init |
| git | gitconfig (personal default), global gitignore |
| starship | prompt theme (Catppuccin Mocha) |
| ghostty | terminal config |
| mise | runtime versions (node, python, java) |
| hammerspoon | app launcher shortcuts |
| ssh | 1Password SSH agent |

## Hammerspoon shortcuts

| Key | App |
|---|---|
| Ctrl+1 | Firefox |
| Ctrl+2 | Chrome |
| Ctrl+3 | WebStorm |
| Ctrl+4 | Slack |
| Ctrl+5 | Discord |
| Cmd+` | Ghostty |

## Adding a new package

```sh
mkdir -p ~/.dotfiles/foo/.config/foo
mv ~/.config/foo/config ~/.dotfiles/foo/.config/foo/config
cd ~/.dotfiles && stow foo
```

## Company overrides

Git signing keys and emails are applied via `includeIf` in `.gitconfig`, pointing to `~/.gitconfig-github` and `~/.gitconfig-gitlab` (Ansible-managed, not in this repo).
