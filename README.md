# dotfiles

Portable macOS dev environment managed by [GNU Stow](https://www.gnu.org/software/stow/). Secrets and company-specific config are pulled from [1Password](https://1password.com/) at provision time — no Ansible, no vault password, no second repo.

## Quick start

### Fresh machine (3 manual steps)

```sh
# 1. Install 1Password app and sign in
# 2. Enable CLI integration: 1Password → Settings → Developer → "Integrate with 1Password CLI"
# 3. Run bootstrap (everything else is automated):
curl -fsSL https://raw.githubusercontent.com/cjbt/.dotfiles/main/bootstrap.sh | bash -s -- [company]
```

`company` is the name of a 1Password vault (e.g. `latimes`, `personal`). Defaults to `personal`.

### Existing machine / re-provision

```sh
~/.dotfiles/install.sh [company]
```

---

## 1Password vault convention

Every company vault uses the same item names. **Adding a new company = create vault + add items. Zero code changes.**

All items are optional — skipped gracefully if absent. Only the vault itself must exist.

### Optional items

| Item | Fields | Generates |
|---|---|---|
| `Git Config` | `email`, `signing_key` | `~/.gitconfig-github` |
| `GitHub` | `token` | `gh auth login` |
| `Shell Secrets` | any env var fields | `~/.config/secrets/$COMPANY.zsh` |
| `GitLab Config` | `signing_key` | `~/.gitconfig-gitlab` |
| `Claude Code` | `api_key` | appended to secrets file + installs `claude` |

All fields in `Shell Secrets` are exported as environment variables. This covers both secrets (tokens, passwords) and non-secret env vars (org slugs, hostnames, feature flags) — store everything in 1Password so nothing is hardcoded.

---

## What `install.sh` does

1. Install Homebrew (if missing)
2. `brew bundle` from `Brewfile`
3. Create `~/dev/personal` and `~/dev/work`
4. Validate the 1Password vault exists
5. Write `~/.gitconfig-github` from `Git Config` item (optional)
6. Write `~/.gitconfig-gitlab` from `GitLab Config` item (optional)
7. Write `~/.config/secrets/$COMPANY.zsh` from `Shell Secrets` item (optional)
8. `gh auth login` with token from `GitHub` item (optional)
9. Stow all dotfile packages
10. `mise install node@lts python@3.12`
11. Install Claude Code and write `ANTHROPIC_API_KEY` to secrets file (optional)
12. Source `companies/<slug>.sh` if it exists (company-specific steps)

---

## Company scripts

`install.sh` handles generic provisioning. Company-specific steps live in `companies/<slug>.sh` and are sourced automatically at the end of a run.

The slug is derived from the company argument: `basename "$COMPANY" | tr '[:upper:]' '[:lower:]'`

| Invocation | Slug | Script sourced |
|---|---|---|
| `./install.sh latimes` | `latimes` | `companies/latimes.sh` |
| `./install.sh personal` | `personal` | *(not found — skipped)* |

Company scripts inherit all variables (`$COMPANY`, `$DOTFILES_DIR`, `$SECRETS_DIR`) and helper functions (`op_item_exists`, `op_read_field`, `info`, `warn`, `error`).

### LA Times (`companies/latimes.sh`)

| Item | Fields | Generates |
|---|---|---|
| `AWS Platform Dev` | `access_key_id`, `secret_access_key` | `~/.aws/credentials [platform-dev]` |
| `AWS Data Dev` | `access_key_id`, `secret_access_key` | `~/.aws/credentials [data-dev]` |
| `AWS Datadesk` | `access_key_id`, `secret_access_key` | `~/.aws/credentials [datadesk]` |
| `NPM Config` | `scoped_registry`, `registry_host` | `~/.npmrc` |
| `Mise Config` | `java_default`, `java_versions` | installs Java versions + sets global default |

### Adding a new company

1. Create a vault in 1Password with the company name
2. Add standard items from the optional items table above
3. If you need company-specific steps, create `companies/<slug>.sh`
4. Run: `./install.sh newcompany`

---

## Stow packages

| Package | What |
|---|---|
| `zsh` | shell config, aliases, tool init |
| `git` | gitconfig (personal default), global gitignore |
| `starship` | prompt theme (Catppuccin Mocha) |
| `ghostty` | terminal config |
| `mise` | runtime versions (node, python, java) |
| `hammerspoon` | app launcher shortcuts |
| `ssh` | 1Password SSH agent |

### Adding a new package

```sh
mkdir -p ~/.dotfiles/foo/.config/foo
mv ~/.config/foo/config ~/.dotfiles/foo/.config/foo/config
cd ~/.dotfiles && stow foo
```

---

## Hammerspoon shortcuts

| Key | App |
|---|---|
| Ctrl+1 | Firefox |
| Ctrl+2 | Chrome |
| Ctrl+3 | WebStorm |
| Ctrl+4 | Slack |
| Ctrl+5 | Discord |
| Cmd+\` | Ghostty |

---

## File permissions

| Path | Mode |
|---|---|
| `~/.config/secrets/` | `700` |
| `~/.config/secrets/*.zsh` | `600` |
| `~/.gitconfig-github` | `600` |
| `~/.gitconfig-gitlab` | `600` |
| `~/.aws/credentials` | `600` |
| `~/.aws/config` | `600` |
| `~/.npmrc` | `600` |

---

## Verification

```sh
op vault get latimes                          # vault accessible
./install.sh latimes                          # runs without errors
cat ~/.gitconfig-github                       # signing key present
cat ~/.config/secrets/latimes.zsh            # all exports present
gh auth status                                # authenticated
source ~/.zshrc && echo $GITLAB_PRIVATE_TOKEN # secret loaded
ls -la ~/.zshrc                               # symlink to dotfiles
claude --version                              # Claude Code installed
echo $ANTHROPIC_API_KEY                       # key set
```
