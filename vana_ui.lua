require ('common');
require ('globals');
require ('helpers');
local d3d           = require('d3d8');
local ffi           = require('ffi');
local fonts         = require('fonts');
local imgui         = require('imgui');
local prims         = require('primitives');
local scaling       = require('scaling');
local settings      = require('settings');
local config        = require('config');
local vanatime      = require('vanatime');

local vana_ui = { };



vana_ui.drawMinimizedClock = function(vanaclock)
    vanaclock.settings.opacity[1] = math.clamp(vanaclock.settings.opacity[1], 0.125, 1);
    local color = d3d.D3DCOLOR_ARGB(vanaclock.settings.opacity[1] * 255, 255, 255, 255);

    imgui.SetNextWindowSize({-1, -1}, ImGuiCond_Always);
    imgui.SetNextWindowPos({vanaclock.settings.x, vanaclock.settings.y}, ImGuiCond_FirstUseEver);
    imgui.PushStyleColor(ImGuiCol_WindowBg, vanaclock.settings.background.color);
    imgui.PushStyleColor(ImGuiCol_Border, vanaclock.settings.background.color);
    imgui.PushStyleColor(ImGuiCol_BorderShadow, { 1.0, 0.0, 0.0, 1.0});
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });

    if(imgui.Begin("VanaClock" .. "", {true}, bit.bor(ImGuiWindowFlags_NoDecoration))) then
        imgui.PopStyleColor(3);
        imgui.PushStyleColor(ImGuiCol_Text, vanaclock.settings.font.color);
        if (imgui.Button("VanaClock", { 140, 20 })) then
            config.uiSettings.minimize[1] = not config.uiSettings.minimize[1];
        end
        imgui.End();
    else
        imgui.PopStyleColor(3);
    end
    imgui.PopStyleVar(1);
end

vana_ui.drawVanaClock = function (vanaclock) 
    vanaclock.settings.opacity[1] = math.clamp(vanaclock.settings.opacity[1], 0.125, 1);
    local color = d3d.D3DCOLOR_ARGB(vanaclock.settings.opacity[1] * 255, 255, 255, 255);
    local current_vanadate = ashita.ffxi.vanatime.get_current_date();
    local current_vanatime = ashita.ffxi.vanatime.get_timestamp();
    local vana_secs = math.floor(ashita.ffxi.vanatime.get_current_second()) + (60 * math.floor(ashita.ffxi.vanatime.get_current_minute())) + (3600 * math.floor(ashita.ffxi.vanatime.get_current_hour()));
    local earth_time = get_earth_time();
    local airshipDelay = 0;

    imgui.SetNextWindowSize({-1, -1}, ImGuiCond_Always);
    imgui.SetNextWindowPos({vanaclock.settings.x, vanaclock.settings.y}, ImGuiCond_FirstUseEver);
    imgui.PushStyleColor(ImGuiCol_WindowBg, vanaclock.settings.background.color);
    imgui.PushStyleColor(ImGuiCol_Border, vanaclock.settings.background.color);
    imgui.PushStyleColor(ImGuiCol_BorderShadow, { 1.0, 0.0, 0.0, 1.0});
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
    if(imgui.Begin("VanaClock" .. "", {true}, bit.bor(ImGuiWindowFlags_NoDecoration))) then
        if (imgui.BeginTabBar('##vc_tabs', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            if (imgui.BeginTabItem('General Info', nil)) then
                
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Earth Time');
                imgui.Text(string.format(" %s/%s/%s, %s, %s:%s:%s", earth_time.year, earth_time.month, earth_time.day, earth_time.weekday, earth_time.hour, earth_time.minute, earth_time.second));
                imgui.NewLine();
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Vana\'diel Time');
                imgui.Text(string.format(" %s/%s/%s, ", current_vanadate.year, current_vanadate.month, current_vanadate.day));
                imgui.SameLine();
                imgui.TextColored(DayColor[current_vanadate.weekday + 1], VanaDay[current_vanadate.weekday + 1]);
                imgui.SameLine();
                imgui.Text(string.format(", %s", current_vanatime));
                imgui.NewLine();
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Moon Phase');
                imgui.Text(string.format(" %s %s%s", MoonPhase[current_vanadate.moon_phase], current_vanadate.moon_percent, '%%'));


                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Airship/Ferry Times', nil)) then

                imgui.PopStyleColor(3);
                imgui.PushStyleColor(ImGuiCol_Text, vanaclock.settings.font.color);
                imgui.SetWindowFontScale(1.0);

                -- BASTOK ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Bastok Routes');
                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.bastok_to_jeuno);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.bastok)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Bastok -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Jeuno - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_bastok);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Jeuno -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.bastok)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Bastok - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);
                
                imgui.NewLine();

                -- SAN D'ORIA ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'San d\'Oria Routes');
                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.sandoria_to_jeuno);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.sandoria)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" San d'Oria -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Jeuno - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_sandoria);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Jeuno -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.sandoria)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" San d'Oria - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                imgui.NewLine();

                -- WINDURST ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Windurst Routes');
                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.windurst_to_jeuno);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.windurst)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Windurst -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Jeuno - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_windurst);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Jeuno -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.windurst)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Windurst - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                imgui.NewLine();

                -- KAZHAM ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Kazham Routes');
                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.kazham_to_jeuno);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.kazham)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Kazham -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Jeuno - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                airshipDelay = get_next_airship_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_kazham);
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.jeuno)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Jeuno -->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.kazham)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Kazham - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(airshipDelay)));
                imgui.PopStyleVar(1);

                imgui.NewLine();

                -- FERRIES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Selbina/Mhaura Ferry');
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.mhaura)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Mhaura <-->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.selbina)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Selbina - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_ferry_departure_delay(vana_secs, vanaclock.settings.ferries.selbina_to_mhaura))));
                imgui.PopStyleVar(1);

                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('RSE Calendar', nil)) then
    
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Moon Calendar', nil)) then
    
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Crafting Guilds', nil)) then
    
                imgui.EndTabItem();
            end
            imgui.EndTabBar();
        end 
        imgui.NewLine();
        if (imgui.Button("Minimize", { 130, 20 })) then
            config.uiSettings.minimize[1] = not config.uiSettings.minimize[1];
        end
        
        imgui.End();
    else
        imgui.PopStyleColor(3);
    end

    imgui.PopStyleVar(1);
end

return vana_ui;