-- =============================================================================
-- Hammerspoon config -- app launcher shortcuts + auto-reload
-- =============================================================================

-- Auto-reload config on save
local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
    local dominated = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            dominated = true
            break
        end
    end
    if dominated then
        hs.reload()
    end
end)
configWatcher:start()

-- -----------------------------------------------------------------------------
-- App shortcuts: Ctrl+1 through Ctrl+5
-- -----------------------------------------------------------------------------
local appBindings = {
    { key = "1", app = "Firefox"       },  -- personal browser
    { key = "2", app = "Google Chrome"  },  -- work browser
    { key = "3", app = "WebStorm"       },
    { key = "4", app = "Slack"          },
    { key = "5", app = "Discord"        },
}

for _, binding in ipairs(appBindings) do
    hs.hotkey.bind({"ctrl"}, binding.key, function()
        local app = hs.application.launchOrFocus(binding.app)
        if app == nil then
            hs.alert.show("Could not launch " .. binding.app)
        end
    end)
end

hs.alert.show("Hammerspoon config loaded")
