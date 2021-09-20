local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local naughty = require("naughty")
local helpers = require('widgets/helpers')

local function isempty(s)
    return s == nil or s == ''
end

local wifitext = "--"

text = wibox.widget.textbox()
widget = wibox.container.margin(text, 40, 20, 0, 0)


function widget:update()
    local currentssid = helpers:run("nmcli -f NAME c show --active | awk '(NR>1)'")
    if not isempty(currentssid) then wifitext = "直 " .. currentssid
    else wifitext = "睊" end
    text:set_markup(wifitext)
end

function widget.render()
    local connectionType = helpers:run("nmcli -f TYPE c show --active | awk '(NR>1)'")
    return not connectionType == "ethernet"
end

local notification
local function showpopup() 
    naughty.destroy(notification)

    local networks = helpers:run("nmcli device wifi | awk \"(NR>1)\"")
    notification = naughty.notify {
        text = networks,
        title = "Available Networks",
        position = "top_right",
        width = auto
    }
end

helpers:listen(widget)

widget:connect_signal("mouse::enter", function() showpopup() end)
widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

return widget
