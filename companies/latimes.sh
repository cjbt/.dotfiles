# LA Times company-specific provisioning.
# Sourced by install.sh when COMPANY slug matches "latimes".
# Has access to all parent vars ($COMPANY, $DOTFILES_DIR, $SECRETS_DIR)
# and helpers (op_item_exists, op_read_field, info, warn, error).
#
# 1Password items (in $COMPANY vault):
#   "AWS Platform Dev"  — fields: access_key_id, secret_access_key
#   "AWS Data Dev"      — fields: access_key_id, secret_access_key
#   "AWS Datadesk"      — fields: access_key_id, secret_access_key
#   "NPM Config"        — fields: scoped_registry, registry_host → ~/.npmrc
#   "Mise Config"       — fields: java_default, java_versions

# ── AWS credentials ──────────────────────────────────────────────────────────
AWS_ITEMS=("AWS Platform Dev" "AWS Data Dev" "AWS Datadesk")
AWS_PROFILES=("platform-dev" "data-dev" "datadesk")

AWS_CREDS_CONTENT=""
AWS_CONFIG_CONTENT=""

for i in "${!AWS_ITEMS[@]}"; do
  item="${AWS_ITEMS[$i]}"
  profile="${AWS_PROFILES[$i]}"

  if op_item_exists "$COMPANY" "$item"; then
    info "Reading '$item' from '$COMPANY' vault..."
    KEY_ID="$(op_read_field "$COMPANY" "$item" "access_key_id")"
    SECRET="$(op_read_field "$COMPANY" "$item" "secret_access_key")"
    AWS_CREDS_CONTENT+="[${profile}]
aws_access_key_id = ${KEY_ID}
aws_secret_access_key = ${SECRET}

"
    AWS_CONFIG_CONTENT+="[profile ${profile}]
region = us-east-1

"
  fi
done

if [[ -n "$AWS_CREDS_CONTENT" ]]; then
  info "Writing ~/.aws/credentials and ~/.aws/config..."
  mkdir -p ~/.aws
  printf '%s' "$AWS_CREDS_CONTENT" > ~/.aws/credentials
  chmod 600 ~/.aws/credentials
  printf '%s' "$AWS_CONFIG_CONTENT" > ~/.aws/config
  chmod 600 ~/.aws/config
else
  warn "No AWS items found in '$COMPANY' vault — skipping"
fi

# ── NPM Config ───────────────────────────────────────────────────────────────
if op_item_exists "$COMPANY" "NPM Config"; then
  info "Writing ~/.npmrc..."
  SCOPED_REGISTRY="$(op_read_field "$COMPANY" "NPM Config" "scoped_registry")"
  REGISTRY_HOST="$(op_read_field "$COMPANY" "NPM Config" "registry_host")"
  cat > ~/.npmrc <<EOF
${SCOPED_REGISTRY}:registry=https://${REGISTRY_HOST}/
//${REGISTRY_HOST}/:_authToken=\${GITLAB_NPM_TOKEN}
EOF
  chmod 600 ~/.npmrc
else
  warn "No 'NPM Config' item found in '$COMPANY' vault — skipping"
fi

# ── Java versions ─────────────────────────────────────────────────────────────
if op_item_exists "$COMPANY" "Mise Config"; then
  info "Installing Java versions from 'Mise Config'..."
  JAVA_VERSIONS="$(op_read_field "$COMPANY" "Mise Config" "java_versions")"
  JAVA_DEFAULT="$(op_read_field "$COMPANY" "Mise Config" "java_default")"
  for ver in $JAVA_VERSIONS; do
    info "  -> java@$ver"
    mise install java@"$ver"
  done
  if [[ -n "$JAVA_DEFAULT" ]]; then
    mise use --global java@"$JAVA_DEFAULT"
  fi
else
  warn "No 'Mise Config' item found in '$COMPANY' vault — skipping Java install"
fi
