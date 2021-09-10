local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")

local consts = require("consts")

local functions = {}

functions.take_screenshot = function (opts)
    if opts == nil then
        opts = ""
     end
     local sound = "/usr/share/sounds/freedesktop/stereo/screen-capture.oga"
     awful.spawn.easy_async_with_shell("maim ~/Pictures/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png " .. opts,
        function () awful.spawn.with_shell("paplay " .. sound) end
    )
end

functions.set_wallpaper = function(s, wallpaper)
    local wallpaper = wallpaper or beautiful.wallpaper
   -- Re-calculate wallpapers size
   if wallpaper then
      -- If wallpaper is a function, call it with the screen
      if type(wallpaper) == "function" then
         wallpaper = wallpaper(s)
      end
      gears.wallpaper.maximized(wallpaper, s, false)
   end
end

functions.client_menu_toggle = function()
   local instance = nil

   return function ()
      if instance and instance.wibox.visible then
         instance:hide()
         instance = nil
      else
         instance = awful.menu.clients({ theme = { width = 250 } })
      end
   end
end

functions.client_set_border = function (c)
    if c.fullscreen then
        c.border_width = 0
     elseif c.border_width == 0 and not c.no_border then
        c.border_width = beautiful.border_width
     end
end

functions.load_wallpaper = function (wallpaper_path)
   local wallpaper = consts.config_path .. "theme/_wall.jpg"
   -- TODO: replace io.open with a non-blocking
   -- https://awesomewm.org/doc/api/libraries/awful.spawn.html
   local ln = io.popen("ln -sfn '" .. wallpaper_path .. "' '" .. config_path .. "theme/_wall.jpg'")
   ln:close()
   -- set new wallpaper for all screens
   for s = 1, screen.count() do
      functions.set_wallpaper(s, wallpaper)
   end
end

functions.client_resize = function (key, c)
    if c == nil then
        c = client.focus
     end
  
  
     if c.floating then
        if     key == "Up"    then c:relative_move(0, 0, 0, -5)
        elseif key == "Down"  then c:relative_move(0, 0, 0, 5)
        elseif key == "Right" then c:relative_move(0, 0, 5, 0)
        elseif key == "Left"  then c:relative_move(0, 0, -5, 0)
        elseif key == "Next"  then c:relative_move( 20,  20, -40, -40)
        elseif key == "Prior" then c:relative_move(-20, -20,  40,  40)
        else
           return false
        end
     else
        if     key == "Up"    then awful.client.incwfact(-0.05)
        elseif key == "Down"  then awful.client.incwfact(0.05)
        elseif key == "Right" then awful.tag.incmwfact(0.05)
        elseif key == "Left"  then awful.tag.incmwfact(-0.05)
        else
           return false
        end
     end
  
     return true
end

functions.notify_suspended = false

functions.notify_callback = function(args)
    if args.freedesktop_hints ~= nil and args.freedesktop_hints.urgency == "\2" then
        args.ignore_suspend = true
     end
  
     for _, c in pairs(awful.screen.object.get_clients()) do
        if c.fullscreen then
           if not naughty.is_suspended() then
              naughty.suspend()
           end
           return
        end
     end
  
     if naughty.is_suspended() and not functions.notify_suspended then
        naughty.resume()
     end
  
     return args
end

functions.tag_view_nonempty = function (direction, screen)
    local s = screen or awful.screen.focused()

   for i = 1, #s.tags do
      awful.tag.viewidx(direction, s)
      if #s.clients > 0 then
         return
      end
   end
end

functions.unless_gap_resize = function (size, screen, tag)
    local s = screen or awful.screen.focused()
    local t = tag or s.selected_tag
    if size == 0 then
       t.gap = beautiful.useless_gap
    else
       t.gap = t.gap + tonumber(size)
    end
    awful.layout.arrange(s)
end

return functions