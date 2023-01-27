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
            if (imgui.BeginTabItem('General', nil)) then
                
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
                imgui.Text(string.format(" %s %s%s", MoonPhase[getCurrMoonPhase()], current_vanadate.moon_percent, '%%'));


                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Airships', nil)) then

                imgui.PopStyleColor(3);
                imgui.PushStyleColor(ImGuiCol_Text, vanaclock.settings.font.color);

                -- CITIES TO JEUNO ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Cities to Jeuno');
                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.bastok_to_jeuno, 4);
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

                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.sandoria_to_jeuno, 4);
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

                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.windurst_to_jeuno, 4);
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

                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.kazham_to_jeuno, 4);
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

                imgui.NewLine();

                -- JEUNO TO CITIES ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Jeuno to Cities');
                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_bastok, 4);
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

                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_sandoria, 4);
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

                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_windurst, 4);
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

                airshipDelay = get_next_departure_delay(vana_secs, vanaclock.settings.airships.jeuno_to_kazham, 4);
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

                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Ferries', nil)) then

                imgui.PopStyleColor(3);
                imgui.PushStyleColor(ImGuiCol_Text, vanaclock.settings.font.color);

                -- FERRIES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Ferries');
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
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.selbina_to_mhaura, 3))));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.mhaura)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Mhaura <-->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.aht_urhgan)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Whitegate - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.mhaura_to_aht_urhgan, 3))));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.aht_urhgan)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(" Whitegate <-->  ")
                imgui.SameLine();
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.aht_urhgan)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] }); 
                imgui.SameLine();
                imgui.Text(" Nashmau - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.aht_urhgan_to_nashmau, 3))));
                imgui.PopStyleVar(1);

                imgui.NewLine()

                -- Manaclipper ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Bibiki Bay Manaclipper Routes');
                imgui.Text(" Bibiki Bay -->  ")
                imgui.SameLine();
                imgui.Text(" Purgonorgo Isle - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.bibiki_bay_to_purgonorgo_isle, 2))));

                imgui.Text(" Purgonorgo Isle -->  ")
                imgui.SameLine();
                imgui.Text(" Bibiki Bay Isle - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.purgonorgo_isle_to_bibiki_bay, 2))));

                imgui.Text(" Bibiki Bay -->  ")
                imgui.SameLine();
                imgui.Text(" Maliyakaleya Reef Tour - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.bibiki_bay_maliyakaleya_reef_tour, 1))));

                imgui.Text(" Bibiki Bay -->  ")
                imgui.SameLine();
                imgui.Text(" Dhalmel Rock Tour - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.ferries.bibiki_bay_dhalmel_rock_tour, 1))));

                imgui.NewLine();

                -- PHANAUET CHANNEL ROUTES
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Phanauet Channel Barge Routes');
                imgui.Text(" North Landing -->  ")
                imgui.SameLine();
                imgui.Text(" Central Landing - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.barges.north_to_central, 1))));
                
                imgui.Text(" Central Landing -->  ")
                imgui.SameLine();
                imgui.Text(" South Landing via Newtpool - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.barges.central_to_south, 2))));

                imgui.Text(" South Landing -->  ")
                imgui.SameLine();
                imgui.Text(" North Landing - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.barges.south_to_north, 1))));

                imgui.Text(" South Landing -->  ")
                imgui.SameLine();
                imgui.Text(" Central Landing via Emfea - Departs in: ");
                imgui.SameLine();
                imgui.Text(time_to_string(convert_vanaseconds_to_earthseconds(get_next_departure_delay(vana_secs, vanaclock.settings.barges.south_to_central, 1))));

                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('RSE Calendar', nil)) then
                local start_time = nil;
                local end_time = nil;
                local location = nil;

                
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Elvaan');
                start_time = get_next_RSE_start_time(1);
                end_time = get_next_RSE_end_time(1);
                location = get_next_RSE_location(1);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[1], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                start_time = get_next_RSE_start_time(2);
                end_time = get_next_RSE_end_time(2);
                location = get_next_RSE_location(2);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[2], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                imgui.NewLine();

                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Tarutaru');
                start_time = get_next_RSE_start_time(3);
                end_time = get_next_RSE_end_time(3);
                location = get_next_RSE_location(3);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[3], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                start_time = get_next_RSE_start_time(4);
                end_time = get_next_RSE_end_time(4);
                location = get_next_RSE_location(4);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[4], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                imgui.NewLine();


                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Mithra');
                start_time = get_next_RSE_start_time(5);
                end_time = get_next_RSE_end_time(5);
                location = get_next_RSE_location(5);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[5], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                imgui.NewLine();

                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Galka');
                start_time = get_next_RSE_start_time(6);
                end_time = get_next_RSE_end_time(6);
                location = get_next_RSE_location(6);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[6], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                imgui.NewLine();
                
                imgui.TextColored({ 1.0, 0.65, 0.26, 1.0 }, 'Hume');
                start_time = get_next_RSE_start_time(7);
                end_time = get_next_RSE_end_time(7);
                location = get_next_RSE_location(7);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[7], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                start_time = get_next_RSE_start_time(8);
                end_time = get_next_RSE_end_time(8);
                location = get_next_RSE_location(8);
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.AlignTextToFramePadding();
                imgui.Text(string.format("%s - Starts: %s/%s/%s, %s, %s:%s:%s -> %s", 
                            vanaclock.settings.RSE.race[8], start_time.year, start_time.month, start_time.day, start_time.weekday, start_time.hour, start_time.minute, start_time.second, vanaclock.settings.RSE.location[location]));
                imgui.Text(string.format("          Ends: %s/%s/%s, %s, %s:%s:%s",
                            end_time.year, end_time.month, end_time.day, end_time.weekday, end_time.hour, end_time.minute, end_time.second));
                imgui.PopStyleVar(1);

                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Moon Calendar', nil)) then
                local ed = nil;
                local now = os.time();
                local moon_times = '';

                ed = getSelectedPhaseStart(7)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[7] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[7] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.new_moon)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(8)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[8] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[8] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.crescent)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(10)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[10] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[10] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.quarter)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(11)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[11] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[11] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.gibbous)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(1)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[1] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[1] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.full_moon)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(2)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[2] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[2] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.gibbous)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(4)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[4] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[4] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.quarter)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);

                ed = getSelectedPhaseStart(5)
                if(now >= ed.time) then 
                    moon_times = MoonPhase[5] .. "  |  NOW!!!" 
                else
                    moon_times = MoonPhase[5] .. "  |  Starts: " .. string.format("%s/%s/%s, %s, %s:%s:%s", ed.year, ed.month, ed.day, ed.weekday, ed.hour, ed.minute, ed.second);
                end
                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.crescent)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(moon_times);
                imgui.PopStyleVar(1);
    
                imgui.EndTabItem();
            end
            if (imgui.BeginTabItem('Crafting Guilds', nil)) then

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.alchemy)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.alchemy));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.bonecraft)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.bonecraft));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.clothcraft)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.clothcraft));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.cooking)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.cooking));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.fishing)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.fishing));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.goldsmith)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.goldsmith));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.leathercraft)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.leathercraft));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.smithing)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.smithing));
                imgui.PopStyleVar(1);

                imgui.Image(tonumber(ffi.cast("uint32_t", vanaclock.icons.woodworking)), { 64 * vanaclock.settings.scale[1], 64 * vanaclock.settings.scale[1] });
                imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 10 });
                imgui.SameLine();
                imgui.AlignTextToFramePadding();
                imgui.Text(get_guild_status_time(Guild.woodworking));
                imgui.PopStyleVar(1);
    
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