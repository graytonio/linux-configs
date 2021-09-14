--[[

   Awesome WM Tron Legacy Theme 1.5
   Distopico Vegan <distopico [at] riseup [dot] net>
   Licensed under GPL3

--]]
local awful = require("awful")
local shape = require("gears.shape")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local colors = require("colors")

-- Theme basic --
local images_path = os.getenv("HOME") .. "/.config/awesome/images"
local theme_wallpaper = images_path .. "/wall.jpg"
local dpi = xresources.apply_dpi

-- Load wallpaper from different locations --
local wall_directories = {
   os.getenv("HOME") .. "/Pictures/Wallpapers",
   os.getenv("HOME") .. "/Pictures"
}

if colors.wallpaper then
   theme_wallpaper = colors.wallpaper
else
   for i=1, #wall_directories do
      local dir = wall_directories[i]

      if awful.util.file_readable(images_path .. "/_wall.jpg") then
         theme_wallpaper = images_path .. "/_wall.jpg"
         break
      end
      if awful.util.file_readable(dir .. "/wall.png") then
         theme_wallpaper = dir .. "/wall.png"
         break
      elseif awful.util.file_readable(dir .. "/wall.jpg") then
         theme_wallpaper = dir .. "/wall.jpg"
         break
      elseif awful.util.file_readable(dir .. "/wallpaper.png") then
         theme_wallpaper = dir .. "/wallpaper.png"
         break
      elseif awful.util.file_readable(dir .. "/wallpaper.jpg") then
         theme_wallpaper = dir .. "/wallpaper.jpg"
         break
      end
   end
end

-- | Shape definition | --
local shape_info = function(cr, width, height)
   shape.infobubble(cr, width, height, 5)
end

-- | Definition  | --
base_color = colors.bg
opacity_hex = "CC"

-- | THEME | --
theme                                           = {}
theme.theme_path                                = images_path
theme.wallpaper                                 = theme_wallpaper
theme.icon_theme                                = "Papirus-Adapta-Nokto"
theme.font                                      = "Hack Nerd Font Mono 10"

-- | Base | --
theme.base_color                                = base_color
theme.bg_normal                                 = base_color
theme.bg_focus                                  = theme.bg_normal
theme.bg_minimize                               = theme.bg_normal
theme.bg_urgent                                 = base_color

theme.fg_normal                                 = colors.fg
theme.fg_focus                                  = colors.fg
theme.fg_urgent                                 = "#e0c625"
theme.fg_minimize                               = "#15abc3"

-- | Systray | --
theme.bg_systray                                = theme.bg_normal
theme.systray_icon_spacing                      = dpi(5)

-- | Borders | --
theme.useless_gap                               = dpi(5)
theme.border_width                              = dpi(2)
theme.border_normal                             = base_color
theme.border_focus                              = colors.colors1
theme.border_marked                             = "#FFFFFF"

-- | Notification | --
theme.notification_fg                           = "#6F6F6F"
theme.notification_bg                           = "#FFFFFF"
theme.notification_border_color                 = colors.colors1
theme.notification_border_width                 = dpi(2)
theme.notification_max_height                   = 300
theme.notification_width                        = 300
theme.notification_icon_size                    = 30

-- | Menu | --
theme.menu_bg_normal                            = base_color
theme.menu_bg_focus                             = theme.menu_bg_normal
theme.menu_icon                                 = theme.theme_path .. "/icons/menu.png"
theme.menu_submenu_icon                         = theme.theme_path .. "/icons/submenu.png"
theme.menu_height                               = dpi(16)
theme.menu_width                                = dpi(100)

-- | Hotkeys help | --
theme.hotkeys_bg                                = base_color
theme.hotkeys_modifiers_fg                      = "#15abc3"
theme.hotkeys_border_color                      = colors.fg
theme.hotkeys_group_margin                      = 20
theme.hotkeys_shape                             = shape_info

-- | Calendar | --
theme.calendar_month_bg_color                   = base_color
theme.calendar_year_bg_color                    = base_color

-- | Tasklist | --
theme.tasklist_bg_normal                        = base_color.."00"
theme.tasklist_bg_focus                         = colors.colors1
theme.tasklist_fg_normal                        = theme.fg_normal.."CC"
theme.tasklist_fg_focus                         = colors.colors1
theme.tasklist_shape                            = gears.shape.powerline

-- | Taglist squares | --
theme.taglist_fg_focus                          = colors.colors1
theme.taglist_font                              = "Hack Nerd Font Mono 10"
theme.taglist_shape                             = gears.shape.powerline

-- | Separators | --
theme.spr1px                                    = theme.theme_path .. "/separators/spr1px.png"
theme.spr2px                                    = theme.theme_path .. "/separators/spr2px.png"
theme.spr4px                                    = theme.theme_path .. "/separators/spr4px.png"
theme.spr5px                                    = theme.theme_path .. "/separators/spr5px.png"
theme.spr10px                                   = theme.theme_path .. "/separators/spr10px.png"

-- | Misc | --
theme.awesome_icon                              = theme.theme_path .. "/icons/awesome.png"
theme.awesome_icon_w                            = theme.theme_path .. "/icons/awesome_w.png"

theme.colors0 = colors.colors0
theme.colors1 = colors.colors1
theme.colors2 = colors.colors2
theme.colors3 = colors.colors3
theme.colors4 = colors.colors4
theme.colors5 = colors.colors5
theme.colors6 = colors.colors6

return theme
