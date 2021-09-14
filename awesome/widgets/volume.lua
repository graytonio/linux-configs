local wibox = require("wibox")
local awful = require("awful")
local gears = require('gears')
local beautiful = require('beautiful')
local helpers = require("widgets/helpers")

local widget = {}
local volumetext = "--"

widget = wibox.widget.textbox()

function widget:update()
   local status = helpers:run("amixer sget Master")
   local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) or 0
   
   volumetext = "蓼 " .. volume .. "%"

   widget:set_markup(volumetext)
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

local volume = wibox.container.margin(widget, 40, 30, 10, 10)
local background = wibox.container.background(volume, beautiful.colors1, gears.shape.powerline)

return background