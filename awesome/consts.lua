local consts = {}

consts.home_path = os.getenv("HOME") .. "/"
consts.config_path = consts.home_path .. ".config/awesome/"
consts.theme_path = consts.home_path .. ".cache/wal/colors.json"

consts.terminal = "alacritty"
consts.editor = "vim"
consts.browser = "firefox"

consts.modkey = "Mod4"
consts.altkey = "Mod1"

consts.batterytext = true

consts.app_folders = { "~/.local/share/applications", "/usr/share/applications" }

consts.editor_cmd = consts.terminal .. " -e " .. consts.editor

return consts