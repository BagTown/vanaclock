require ('common');

local ffi   = require('ffi');
local imgui = require("imgui");

local config = {}
config.uiSettings = {
    is_open = { false },
    font_changed = { false },
    minimize = { true }, 
}

return config;