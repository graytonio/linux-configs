local wibox = require("wibox")
local awful = require("awful")
local gears = require('gears')
local beautiful = require('beautiful')
local helpers = require("widgets/helpers")

local volumetext = "--"

text = wibox.widget.textbox()
widget = wibox.container.margin(text, 40, 30, 0, 0)

function widget:update()
   local status = helpers:run("amixer sget Master")
   local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) or 0
   
   volumetext = "蓼 " .. volume .. "%"

   text:set_markup(volumetext)
end

function widget:raise()
   awful.spawn("amixer set Master 1%+", false)
   helpers:delay(widget.update, 0.1)
end

function widget:lower()
   awful.spawn("amixer set Master 1%-", false)
   helpers:delay(widget.update, 0.1)
end

function widget:mute()
   awful.spawn("amixer -D pulse set Master 1+ toggle", false)
   helpers:delay(widget.update, 0.1)
end

helpers:listen(widget, 40)

return widget
