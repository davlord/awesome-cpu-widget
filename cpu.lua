
local gtable = require("gears").table

local cpu = { mt = {} }

local function get_cpu_state(c)
    return {
        idle= c.idle,
        total= c.total,
    }
end

local function get_cpu_percentage(old_cpu_state, new_cpu_state)
    local idle_delta = new_cpu_state.idle - old_cpu_state.idle
    local total_delta = new_cpu_state.total - old_cpu_state.total
    return 100.0 * (1.0 - idle_delta / total_delta)
end

function cpu:update(c)
    self.old_cpu_state = self.new_cpu_state
    self.new_cpu_state = get_cpu_state(c)
    self.percentage = get_cpu_percentage(self.old_cpu_state, self.new_cpu_state)
end

local function new()
   
    local initial_state = {
        idle = 0,
        total = 0
    }

    local c = {
        old_cpu_state = initial_state,
        new_cpu_state = initial_state,
        percentage = nil
    }

    gtable.crush(c, cpu, true)

    return c
end

function cpu.mt:__call(...)
    return new(...)
end

return setmetatable(cpu, cpu.mt)