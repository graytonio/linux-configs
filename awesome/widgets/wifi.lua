local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local naughty = require("naughty")
local helpers = require('widgets/helpers')

local widget = {}
local wifitext = "--"

widget = wibox.widget.textbox()

local function isempty(s)
    return s == nil or s == ''
end

function widget:update()
    local currentssid = helpers:run("nmcli -f NAME c show --active | awk '(NR>1)'")
    if not isempty(currentssid) then wifitext = "直 " .. currentssid
    else wifitext = "睊" end

    widget:set_markup(wifitext)
end

local notification
local function showpopup() 
    naughty.destroy(notification)
    -- notification = naughty.notify {
    --     text = wifitext,
    --     position = "top_right",
    -- }

    local networks = helpers:run("nmcli device wifi | awk \"(NR>1)\"")
    notification = naughty.notify {
        text = networks,
        title = "Available Networks",
        position = "top_right",
        width = 1920
    }
end

helpers:listen(widget)

local margin = wibox.container.margin(widget, 40, 20, 10, 10)
local background = wibox.container.background(margin, beautiful.colors2, gears.shape.powerline)

background:connect_signal("mouse::enter", function() showpopup() end)
background:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

return background