--Based off the MithraPride and pyogenes.com vanadiel clock
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

addon.name      = 'VanaClock';
addon.author    = 'Bag_Town';
addon.version   = '0.8';
addon.desc      = 'Displays an in-game timer clock for airships, moon phase, RSE times, and Guild times';
addon.link      = 'https://ashitaxi.com/';

require ('common');
require ('globals');
require ('helpers');
local chat          = require('chat');
local d3d           = require('d3d8');
local ffi           = require('ffi');
local fonts         = require('fonts');
local imgui         = require('imgui');
local prims         = require('primitives');
local scaling       = require('scaling');
local settings      = require('settings');
local config        = require('config');
local vana_ui       = require('vana_ui');
local vanatime      = require('vanatime');

local C = ffi.C;
local d3d8dev = d3d.get_device();

local vanaclock = T{ 
    icons = T { 
        bastok          = nil;
        sandoria        = nil;
        windurst        = nil;
        jeuno           = nil;
        aht_urhgan      = nil;
        selbina         = nil;
        mhaura          = nil;
        kazham          = nil;

        alchemy         = nil;
        blacksmith      = nil;
        bonecraft       = nil;
        clothcraft      = nil;
        cooking         = nil;
        goldsmith       = nil;
        fishing         = nil;
        leatherworking  = nil;
        woodworking     = nil;    
        
        new_moon        = nil;
        crescent        = nil;
        quarter         = nil;
        gibbous         = nil;
        full_moon       = nil;
    };

    RSE = T { race = '', starting_time = 0, ending_time = 0, location = '', vanadiel_time = 0 },

    sprite = nil;
    rect = ffi.new('RECT', { 0, 0, 64, 64, });
    vec_position = ffi.new('D3DXVECTOR2', { 0, 0, }),
    vec_scale = ffi.new('D3DXVECTOR2', { 0.5, 0.5, }),

    settings = settings.load(Default_settings),
};

ffi.cdef[[
    // Exported from Addons.dll
    HRESULT __stdcall D3DXCreateTextureFromFileA(IDirect3DDevice8* pDevice, const char* pSrcFile, IDirect3DTexture8** ppTexture);
]];



--[[
* Loads a icon texture from the /addons/vanaclock/assets/ folder

* @param {int} - asset number for png file loading 
--]]
local function load_asset_texture(asset)
    if (asset == -1) then return nil; end

    local path = ('%saddons\\%s\\assets\\'):append(type(asset) == 'number' and '%d' or '%s'):append('.png'):fmt(AshitaCore:GetInstallPath(), 'vanaclock', asset);
    if (not ashita.fs.exists(path)) then
        return nil;
    end

    local texture_ptr = ffi.new('IDirect3DTexture8*[1]');
    if (C.D3DXCreateTextureFromFileA(d3d8dev, path, texture_ptr) ~= C.S_OK) then
        return nil;
    end
    return d3d.gc_safe_release(ffi.new('IDirect3DTexture8*', texture_ptr[0]));
end

--[[
* Prints the addon help information

* @param {boolean} isError - Flag if this function was invoked due to an error.
--]]
local function print_help(isError)
    if (isError) then
        print(chat.header(addon.name):append(chat.error('Invalid command syntax for command: ')):append(chat.success('/' .. addon.name)));
    else
        print(chat.header(addon.name):append(chat.message('Available commands:')));
    end

    local cmds = T{
        { '/[ vanaclock | vc ] config', 'Brings up the configuration window.' },
        { '/[ vanaclock | vc ] show ', 'Toggles whether vanaclock is displayed or not.' },
        { '/[ vanaclock | vc ] help', 'Help and available commands.' },
    };

    -- Print the command list.
    cmds:ieach(function (v)
        print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
    end);
end

local function print_debug()
    
end

--[[
* Updates the saved settings to the new values

* @param {s} - The settings table 
--]]
local function update_settings(s)
    if (s ~= nil) then
        vanaclock.settings = s;
    end

    settings.save();
end

--[[
* event: command
* desc: Event called when the addon is processing a command
--]]
ashita.events.register('command', 'command_cb', function(e)
    --Parse the command arguments.
    local args = e.command:args();
    if (#args > 0 and (args[1]:any('/vanaclock') or args[1]:any('/vc'))) then
        e.blocked = true;

        if(#args == 2 and args[2]:any('config')) then
            config.uiSettings.is_open[1] = not config.uiSettings.is_open[1];
            return;
        end

        if(#args == 2 and args[2]:any('show')) then
            vanaclock.settings.visible = not vanaclock.settings.visible;
            return;
        end

        if(#args == 2 and args[2]:any('printdebug')) then
            print_debug();
            return;
        end

        print_help(true);
    else
        return;
    end

end);

--[[
* event: d3d_beginscene
* desc : Event called when the Direct3D device is beginning a scene.
--]]
ashita.events.register('d3d_beginscene', 'beginscene_cb', function (isRenderingBackBuffer)
    if (not isRenderingBackBuffer) then return; end
end);   

--[[
* event: d3d_present
* desc: Event called when the addon is being rendered.
--]]

ashita.events.register('d3d_present', 'present_cb', function()
    if (vanaclock.sprite == nil) then
        return;
    end
    if(config.uiSettings.minimize[1]) then
        vana_ui.drawMinimizedClock(vanaclock);
    else
        vana_ui.drawVanaClock(vanaclock);
    end
end);

--[[
* event: load
* desc: First called when our addon is loaded.
--]]
ashita.events.register('load', 'load_cb', function()
    vanaclock.settings.x[1] = scaling.window.w - scaling.scale_width(150);
    vanaclock.settings.y[1] = scaling.window.h - scaling.scale_height(40);

    -- Preload all the textures so not constantly reading from disk.
    vanaclock.icons.bastok = load_asset_texture('bastok');
    vanaclock.icons.sandoria = load_asset_texture('sandoria');
    vanaclock.icons.windurst = load_asset_texture('windurst');
    vanaclock.icons.jeuno = load_asset_texture('jeuno');
    vanaclock.icons.aht_urhgan = load_asset_texture('ahturhgan');
    vanaclock.icons.mhaura = load_asset_texture('mhaura');
    vanaclock.icons.selbina = load_asset_texture('selbina');
    vanaclock.icons.kazham = load_asset_texture('kazham');

    vanaclock.icons.alchemy = load_asset_texture('alchemy');
    vanaclock.icons.bonecraft = load_asset_texture('bonecraft');
    vanaclock.icons.clothcraft = load_asset_texture('clothcraft');
    vanaclock.icons.cooking = load_asset_texture('cooking');
    vanaclock.icons.fishing = load_asset_texture('fishing');
    vanaclock.icons.goldsmith = load_asset_texture('goldsmithing');
    vanaclock.icons.leathercraft = load_asset_texture('leathercraft');
    vanaclock.icons.smithing = load_asset_texture('smithing');
    vanaclock.icons.woodworking = load_asset_texture('woodworking');

    vanaclock.icons.new_moon = load_asset_texture('newmoon');
    vanaclock.icons.crescent = load_asset_texture('crescentmoon');
    vanaclock.icons.quarter = load_asset_texture('quartermoon');
    vanaclock.icons.gibbous = load_asset_texture('gibbousmoon');
    vanaclock.icons.full_moon = load_asset_texture('fullmoon');

    local sprite_ptr = ffi.new('ID3DXSprite*[1]');
    if (C.D3DXCreateSprite(d3d8dev, sprite_ptr) ~= C.S_OK) then
        error('failed to make sprite obj');
    end
    vanaclock.sprite = d3d.gc_safe_release(ffi.cast('ID3DXSprite*', sprite_ptr[0]));
end);

--[[
* event: packet_in
* desc: Called when our addon receives an incoming packet.
--]]
ashita.events.register('packet_in', 'packet_in_cb', function(e)
end);

--[[
* event: packet_out
* desc: Called when our addon receives an outgoing packet.
--]]
ashita.events.register('packet_out', 'packet_out_cb', function(e)
end);

--[[
* Registers a callback for the settings to monitor for character switches.
--]]
settings.register('settings', 'settings_update', update_settings);

--[[
* event: unload 
* desc: Called when our addon is unloaded.
--]]
ashita.events.register('unload', 'unload_cb', function()
    update_settings();
    for key, value in pairs(vanaclock.icons) do
        value = nil;
    end

    sprite = nil;
end);