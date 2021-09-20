local wibox = require("wibox")
local awful = require("awful")
local gears = require('gears')
local beautiful = require('beautiful')
local naughty = require("naughty")
local helpers = require("widgets/helpers")

local batterytext = "--"

local adapter = "BAT0"
local acAdapter = "AC0"
local charge = "charge"

text = wibox.widget.textbox()
widget = wibox.container.margin(text, 40, 20, 0, 0)

function widget.render() 
   return widget.hasbattery
end

function widget:check()
   local adapters = string.gmatch(helpers:run("ls /sys/class/power_supply/"), "%S+")
   for value in adapters do
      if value:match("^A") then
         acAdapter = value
      elseif value:match("^B") then
         adapter = value
      end
   end

   charge = "charge"
   widget.hasbattery = helpers:test("cat /sys/class/power_supply/" .. adapter .. "/" .. charge .. "_now")

   if not widget.hasbattery then
      charge = "energy"
      widget.hasbattery = helpers:test("cat /sys/class/power_supply/" .. adapter .. "/" .. charge .. "_now")
   end
end

function widget:update()
   local sendNotify = false
   local cur = helpers:run("cat /sys/class/power_supply/" ..adapter .. "/" .. charge .. "_now")
   local cap = helpers:run("cat /sys/class/power_supply/" ..adapter .. "/" .. charge .. "_full")
   local sta = helpers:run("cat /sys/class/power_supply/" ..adapter .. "/status")
   local ac = helpers:run("cat /sys/class/power_supply/" ..acAdapter .. "/online")

   if cur and cap then
      local acStatus = ac ~= "" and math.floor(ac) or 0;
      local battery = math.floor(cur * 100 / cap)
      local toHibernate = false

      if acStatus == 1 then
         batterytext = "⚡".. battery .. "%"
      else
         batterytext = " " .. battery .. "%"
      end

      text:set_markup(batterytext)

      if ((battery == 18 or battery == 10 or battery < 5) and sta:match("Discharging")) then
         sendNotify = true
         batterytext = batterytext .. "  Warning low level batery!"

         if(toHibernate) then
            batterytext = batterytext .. "  - Prepare Hibernate"
            helpers:delay(function() awful.spawn("systemctl hibernate") end, 10)
         end
      end

      if (sendNotify) then
         naughty.notify({
               text = batterytext,
               timeout = 4, hover_timeout = 0.5,
               screen = mouse.screen,
               ignore_suspend = true
         })
      end

   else
      text:set_markup("N/A")
   end
end

widget:check()

if widget.hasbattery then
   helpers:listen(widget, 10)
end

return widget
