export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"


# Added by Toolbox App
export PATH="$PATH:/Users/ctantay/Library/Application Support/JetBrains/Toolbox/scripts"


export NPM_CONFIG_USERCONFIG="$HOME/.npmrc"
if ! grep -q '@caltimes:registry' ~/.npmrc 2>/dev/null; then
  echo '@caltimes:registry=https://gitlab.com/api/v4/packages/npm/
//gitlab.com/api/v4/packages/npm/:_authToken=${GITLAB_PRIVATE_TOKEN}' >> ~/.npmrc
fi
