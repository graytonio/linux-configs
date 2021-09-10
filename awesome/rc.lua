--[[
    Awesome WM Configuration
    Grayton Ward
--]] 
-- Import Libraries
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local cyclefocus = require("libs/cyclefocus")
local consts = require("consts")
local functions = require("functions")

local batterywidget = require("widgets/battery")
local volumewidget = require("widgets/volume")

require("awful.autofocus")

naughty.config.notify_callback = functions.notify_callback
naughty.config.defaults.timeout = 10

cyclefocus.show_clients = false
cyclefocus.focus_clients = false
cyclefocus.display_prev_count = 1
cyclefocus.default_preset = {
    timeout = 0,
    margin = 3,
    border_width = 1,
    border_color = "#001E21",
    fg = "#00ffff",
    bg = "#001214"
}

-- Available Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating
    --   awful.layout.suit.tile.left,
    --   awful.layout.suit.tile.bottom,
    --   awful.layout.suit.tile.top,
    --   awful.layout.suit.fair,
    --   awful.layout.suit.fair.horizontal,
    --   awful.layout.suit.spiral,
    --   awful.layout.suit.spiral.dwindle,
    --   awful.layout.suit.max,
    --   awful.layout.suit.max.fullscreen,
    --   awful.layout.suit.magnifier,
    --   awful.layout.suit.corner.nw,
    --   awful.layout.suit.corner.ne,
    --   awful.layout.suit.corner.sw,
    --   awful.layout.suit.corner.se,
}

-- Catch Startup Errors
if awesome.startup_errors then
    naughty.notify(
        {
            preset = naughty.config.presets.critical,
            title = "Startup Error",
            text = awesome.startup_errors
        }
    )
end

-- Catch Runtime Errors
do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
        function(err)
            if in_error then
                return
            end
            in_error = true

            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Runtime Error",
                    text = tostring(err)
                }
            )
        end
    )
end

beautiful.init(consts.config_path .. "theme.lua")

-- #region Launcher Widget

-- Awesome Submenu
local awesomemenu = {
    {"&hotkeys", function()
            return false, hotkeys_popup.show_help
        end},
    {"&manual", consts.terminal .. " -e man awesome"},
    {"&edit config", consts.editor_cmd .. " " .. awesome.conffile},
    {"&restart", awesome.restart},
    {"&quit", function()
            awesome.quit()
        end}
}

-- System Submenu
local systemmenu = {}

-- Main Dropdown Menu
local mainmenu =
    awful.menu(
    {
        items = {
            {"&Awesome", awesomemenu},
            {"&System", systemmenu},
            {"&Terminal", consts.terminal}
        }
    }
)

local launcher =
    awful.widget.launcher(
    {
        image = beautiful.awesome_icon_w,
        menu = mainmenu
    }
)

menubar.menu_gen.all_menu_dirs = consts.app_folders
menubar.utils.terminal = consts.terminal
-- #endregion

-- #region Wibar
local taglist_buttons =
    gears.table.join(
    awful.button(
        {},
        1,
        function(t)
            t:view_only()
        end
    ),
    awful.button(
        {consts.modkey},
        1,
        function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end
    ),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button(
        {consts.modkey},
        3,
        function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end
    ),
    awful.button(
        {},
        4,
        function(t)
            awful.tag.viewnext(t.screen)
        end
    ),
    awful.button(
        {},
        5,
        function(t)
            awful.tag.viewprev(t.screen)
        end
    )
)

local tasklist_buttons =
    gears.table.join(
    awful.button(
        {},
        1,
        function(c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() and c.first_tag then
                    c.first_tag:view_only()
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end
    ),
    awful.button({}, 3, functions.client_menu_toggle()),
    awful.button(
        {},
        4,
        function()
            awful.client.focus.byidx(1)
        end
    ),
    awful.button(
        {},
        5,
        function()
            awful.client.focus.byidx(-1)
        end
    )
)

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local mysystray = wibox.widget.systray()
local mysystraymargin = wibox.container.margin(mysystray, 2, 2, 2, 2)

awful.screen.connect_for_each_screen(
    function(s)
        -- Widget separators
        local separator1px = wibox.widget.imagebox()
        separator1px:set_image(beautiful.get().spr1px)
        local separator2px = wibox.widget.imagebox()
        separator2px:set_image(beautiful.get().spr2px)
        local separator4px = wibox.widget.imagebox()
        separator4px:set_image(beautiful.get().spr4px)
        local separator5px = wibox.widget.imagebox()
        separator5px:set_image(beautiful.get().spr5px)
        local separator10px = wibox.widget.imagebox()
        separator10px:set_image(beautiful.get().spr10px)

        local textseparator = wibox.widget.textbox()
        textseparator.markup = "<b> | </b>"

        -- Set Wallpaper Here
        functions.set_wallpaper(s)

        -- Tag Table
        local layouts = awful.layout.layouts
        local tags = {
            names = {"1", "2", "3", "4", "5", "6"},
            layouts = {
                layouts[1],
                layouts[1],
                layouts[1],
                layouts[1],
                layouts[1],
                layouts[1]
            }
        }
        awful.tag(tags.names, s, tags.layouts)

        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
        s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

        s.mywibox = awful.wibox({position = "top", screen = s, height = 50})

        local left_layout = wibox.layout.fixed.horizontal()
        if (s.index == 1) then
            left_layout:add(launcher)
        end
        left_layout:add(s.mytaglist)
        left_layout:add(s.mypromptbox)
        left_layout:add(separator10px)

        local textclock = wibox.widget.textclock()

        local right_layout = wibox.layout.fixed.horizontal()
        if s.index == 1 then
            right_layout:add(volumewidget.icon)
            right_layout:add(textseparator)

            if batterywidget.hasbattery then
                if consts.batterytext then
                    right_layout:add(batterywidget.text)
                else
                    right_layout:add(batterywidget.icon)
                end
            end

            right_layout:add(textseparator)
            right_layout:add(textclock)
        end

        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            left_layout,
            s.mytasklist,
            right_layout
        }
    end
)
-- #endregion

-- #region Mouse Bindings
root.buttons(
    gears.table.join(
        awful.button(
            {},
            3,
            function()
                mainmenu:toggle()
            end
        ),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    )
)
-- #endregion

-- #region Key bindings
local globalkeys =
    gears.table.join(
    awful.key(
        {consts.modkey},
        "s",
        hotkeys_popup.show_help,
        {
            description = "show help",
            group = "awesome"
        }
    ),
    awful.key({consts.modkey}, "Left", awful.tag.viewprev, {description = "view previous", group = "tag"}),
    awful.key(
        {consts.modkey},
        "Right",
        awful.tag.viewnext,
        {
            description = "view next",
            group = "tag"
        }
    ),
    awful.key({consts.modkey}, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
    -- Non-empty tag browsing
    awful.key(
        {consts.modkey},
        "Next",
        function()
            functions.tag_view_nonempty(1)
        end,
        {description = "focus next non-empty tag", group = "tag"}
    ),
    awful.key(
        {consts.modkey},
        "Prior",
        function()
            functions.tag_view_nonempty(-1)
        end,
        {description = "focus previous non-empty tag", group = "tag"}
    ),
    -- Unless gaps resize
    awful.key(
        {consts.modkey, "Control"},
        "+",
        function()
            functions.unless_gap_resize(1)
        end,
        {
            description = "increase unless gap size on current screen and tag",
            group = "layout"
        }
    ),
    awful.key(
        {consts.modkey, "Control"},
        "-",
        function()
            functions.unless_gap_resize(-1)
        end,
        {
            description = "reduce unless gap size on current screen and tag",
            group = "layout"
        }
    ),
    awful.key(
        {consts.modkey, "Control"},
        "0",
        function()
            functions.unless_gap_resize(0)
        end,
        {
            description = "reset unless gap size on current screen and tag",
            group = "layout"
        }
    ), -- Take a screenshot
    awful.key({}, "Print", functions.take_screenshot, {description = "print a screenshot", group = "screenshot"}),
    awful.key(
        {consts.altkey},
        "Print",
        function()
            functions.take_screenshot("--delay=10")
        end,
        {description = "print a screenshot after 10 sec", group = "screenshot"}
    ),
    awful.key(
        {consts.modkey},
        "Print",
        function()
            functions.take_screenshot("-s")
        end,
        {description = "print a screenshot by area", group = "screenshot"}
    ),
    -- Default client focus
    awful.key(
        {consts.modkey},
        "j",
        function()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "k",
        function()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "focus previous by index", group = "client"}
    ),
    -- Layout manipulation
    awful.key(
        {consts.modkey, "Shift"},
        "j",
        function()
            awful.client.swap.byidx(1)
        end,
        {description = "swap with next client by index", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "k",
        function()
            awful.client.swap.byidx(-1)
        end,
        {description = "swap with previous client by index", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "j",
        function()
            awful.screen.focus_relative(1)
        end,
        {description = "focus the next screen", group = "screen"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "k",
        function()
            awful.screen.focus_relative(-1)
        end,
        {description = "focus the previous screen", group = "screen"}
    ),
    awful.key(
        {consts.modkey},
        "u",
        awful.client.urgent.jumpto,
        {
            description = "jump to urgent client",
            group = "client"
        }
    ),
    awful.key(
        {consts.modkey},
        "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}
    ),
    awful.key(
        {consts.altkey},
        "Tab",
        function(c)
            cyclefocus.cycle(1)
        end,
        {
            description = "cycle focus next client",
            group = "client"
        }
    ),
    awful.key(
        {consts.altkey, "Shift"},
        "Tab",
        function(c)
            cyclefocus.cycle(-1)
        end,
        {description = "cycle focus previous client", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "l",
        function()
            functions.client_resize("Right")
        end,
        {description = "increase master width factor", group = "layout"}
    ),
    awful.key(
        {consts.modkey},
        "h",
        function()
            functions.client_resize("Left")
        end,
        {description = "decrease master width factor", group = "layout"}
    ),
    awful.key(
        {consts.modkey, consts.altkey},
        "l",
        function()
            functions.client_resize("Up")
        end,
        {description = "increase client height factor", group = "layout"}
    ),
    awful.key(
        {consts.modkey, consts.altkey},
        "h",
        function()
            functions.client_resize("Down")
        end,
        {description = "decrease client height factor", group = "layout"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "h",
        function()
            awful.tag.incnmaster(1)
        end,
        {
            description = "increase the number of master clients",
            group = "layout"
        }
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "l",
        function()
            awful.tag.incnmaster(-1)
        end,
        {
            description = "decrease the number of master clients",
            group = "layout"
        }
    ),
    awful.key(
        {consts.modkey, "Control"},
        "h",
        function()
            awful.tag.incncol(1)
        end,
        {
            description = "increase the number of columns",
            group = "layout"
        }
    ),
    awful.key(
        {consts.modkey, "Control"},
        "l",
        function()
            awful.tag.incncol(-1)
        end,
        {
            description = "decrease the number of columns",
            group = "layout"
        }
    ),
    awful.key(
        {consts.modkey},
        "space",
        function()
            awful.layout.inc(layouts, 1)
        end,
        {description = "select next layout", group = "layout"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "space",
        function()
            awful.layout.inc(layouts, -1)
        end,
        {description = "select previous layout", group = "layout"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "t",
        function()
            awful.layout.set(awful.layout.suit.tile)
        end,
        {description = "switch to tile layout", group = "layout"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "f",
        function()
            awful.layout.set(awful.layout.suit.floating)
        end,
        {description = "switch to floating layout", group = "layout"}
    ),
    -- Standard program
    awful.key(
        {consts.modkey},
        "Return",
        function()
            awful.spawn(consts.terminal)
        end,
        {description = "open a terminal", group = "launcher"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "r",
        awesome.restart,
        {
            description = "reload awesome",
            group = "awesome"
        }
    ),
    awful.key({consts.modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),
    awful.key({}, "XF86AudioRaiseVolume", volumewidget.raise),
    awful.key({}, "XF86AudioLowerVolume", volumewidget.lower),
    awful.key({}, "XF86AudioMute", volumewidget.mute),
    -- Notifications
    awful.key(
        {consts.modkey, "Shift"},
        "s",
        function()
            -- TODO: move to external widget with icon
            if naughty.is_suspended() then
                functions.notify_suspended = false
                naughty.resume()
            else
                functions.notify_suspended = true
                naughty.suspend()
            end
        end,
        {description = "enabled/disable notifications", group = "awesome"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "d",
        naughty.destroy_all_notifications,
        {
            description = "clear notifications",
            group = "awesome"
        }
    ), -- Prompt
    awful.key(
        {consts.modkey},
        "d",
        function()
            awful.util.spawn("rofi -show run")
        end,
        {description = "open app launcher", group = "launcher"}
    ), -- Menubar
    awful.key(
        {consts.altkey},
        "Escape",
        function()
            -- If you want to always position the menu on the same place set coordinates
            awful.menu.menu_keys.down = {"Down", "Alt_L"}
            awful.menu.clients({theme = {width = 250}}, {keygrabber = true, coords = {x = 525, y = 330}})
        end,
        {description = "show app switcher", group = "awesome"}
    ),
    awful.key(
        {consts.modkey},
        "a",
        function()
            awful.spawn("rofi -show", false)
        end,
        {description = "show rofi", group = "launcher"}
    )
)

local clientkeys =
    gears.table.join(
    awful.key(
        {consts.modkey},
        "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}
    ),
    awful.key(
        {consts.altkey},
        "F2",
        function(c)
            if c.pid then
                awful.spawn("kill -9 " .. c.pid)
            else
                awful.spawn("xkill")
            end
        end,
        {description = "kill", group = "client"}
    ),
    awful.key(
        {consts.altkey},
        "F4",
        function(c)
            c:kill()
        end,
        {
            description = "close",
            group = "client"
        }
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "c",
        function(c)
            c:kill()
        end,
        {description = "close", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "space",
        awful.client.floating.toggle,
        {
            description = "toggle floating",
            group = "client"
        }
    ),
    awful.key(
        {consts.modkey, "Control"},
        "Return",
        function(c)
            c:swap(awful.client.getmaster())
        end,
        {description = "move to master", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "Left",
        function(c)
            awful.client.setmaster(c)
        end,
        {description = "set to master", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "Right",
        function(c)
            awful.client.setslave(c)
        end,
        {description = "move to slave", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "o",
        function(c)
            c:move_to_screen()
        end,
        {description = "move to screen", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "t",
        function(c)
            c.ontop = not c.ontop
        end,
        {description = "toggle keep on top", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "y",
        function(c)
            c.sticky = not c.sticky
        end,
        {description = "toggle keep sticky", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "t",
        function(c)
            awful.titlebar.toggle(c)
        end,
        {description = "toggle title bar", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        {description = "minimize", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "(un)maximize", group = "client"}
    ),
    awful.key(
        {consts.modkey, consts.altkey},
        "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {description = "(un)maximize horizontally/vertically", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Shift"},
        "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        {description = "(un)maximize horizontally", group = "client"}
    ),
    awful.key(
        {consts.modkey, "Control"},
        "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {description = "(un)maximize vertically", group = "client"}
    ), -- Snap
    awful.key(
        {consts.modkey},
        "Up",
        function(c)
            c.maximized = true
            c:raise()
        end,
        {description = "maximize", group = "client"}
    ),
    awful.key(
        {consts.modkey},
        "Down",
        function(c)
            c.maximized = false
            c:raise()
            awful.placement.centered(c, nil)
        end,
        {description = "unmaximize", group = "client"}
    )
)

for i = 1, 9 do
    globalkeys =
        gears.table.join(
        globalkeys, -- View tag only.
        awful.key(
            {consts.modkey},
            "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #" .. i, group = "tag"}
        ),
        -- Toggle tag display.
        awful.key(
            {consts.modkey, "Control"},
            "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}
        ),
        -- Move client to tag.
        awful.key(
            {consts.modkey, "Shift"},
            "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #" .. i, group = "tag"}
        ),
        -- Toggle tag on focused client.
        awful.key(
            {consts.modkey, "Control", "Shift"},
            "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"}
        )
    )
end

local clientbuttons =
    gears.table.join(
    awful.button(
        {},
        1,
        function(c)
            client.focus = c
            c:raise()
        end
    ),
    awful.button({consts.modkey}, 1, awful.mouse.client.move),
    awful.button({consts.modkey}, 3, awful.mouse.client.resize)
)

root.keys(globalkeys)
-- #endregion

-- #region Rules
local screen_max = screen:count()
awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            titlebars_enabled = false,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },
    {
        rule_any = {
            instance = {"copyq"},
            class = {
                "Arandr",
                "Gpick",
                "Kruler",
                "Sxiv",
                "Tor Browser",
                "Wpa_gui",
                "pinentry",
                "veromix",
                "xtightvncviewer"
            },
            name = {"Event Tester"},
            role = {"AlarmWindow", "pop-up", "About"}
        },
        properties = {floating = true}
    },
    {
        rule_any = {
            name = {
                "Open Folder",
                "Open File"
            }
        },
        properties = {
            floating = true,
            modal = true,
            width = 1920,
        }
    }
}
-- #endregion

-- #region Signals
screen.connect_signal(
    "property::geometry",
    function(s)
        functions.set_wallpaper(s)
    end
)
client.connect_signal(
    "manage",
    function(c)
        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_offscreen(c)
        end
    end
)

client.connect_signal(
    "focus",
    function(c)
        c.border_color = beautiful.border_focus
    end
)
client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)
client.connect_signal("property::size", functions.client_set_border)
client.connect_signal("property::fullscreen", functions.client_set_border)
-- #endregion
