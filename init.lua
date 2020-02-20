local setmetatable = setmetatable
local math = math
local lgi = require "lgi"
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local GTop = lgi.GTop
local cpu = require("awesome-cpu-widget.cpu")

local cpu_widget = { mt = {} }

local function round(value)
    return math.floor(value + 0.5)
end

function cpu_widget:update_text()
    local text = string.format("%02d%%", round(self._private.cpu.percentage))
    self.textbox:set_text(text)
end

function cpu_widget:update_tooltip()
end

function cpu_widget:update()
    GTop.glibtop_get_cpu(self._private.glibtop_cpu)
    self._private.cpu:update(self._private.glibtop_cpu)
    self:update_text()
    self:update_tooltip()
end

local function new(args)
    local w = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 4,
        {
            id = "iconbox",
            widget = wibox.widget.textbox,
            font = "FontAwesome 12",
            text = ""
        },
        {
            id = "textbox",
            widget = wibox.widget.textbox,
        }        
    }

    GTop.glibtop_init()

    w.tooltip = awful.tooltip({ objects = { w },})
    
    w._private.glibtop_cpu = GTop.glibtop_cpu()
    w._private.cpu = cpu()

    gears.table.crush(w, cpu_widget, true)

    local update_timer = gears.timer {
        timeout   = 5,
        callback = function() w:update() end
    }
    update_timer:start()

    w:update()

    return w
end

function cpu_widget.mt:__call(...)
    return new(...)
end

return setmetatable(cpu_widget, cpu_widget.mt)