function get_earth_time(time)
    local earth_time = { };
    earth_time.year = os.date("%Y", time);
    earth_time.month  = os.date("%m", time); 
    earth_time.day = os.date("%d", time); 
    earth_time.hour = os.date("%H", time); 
    earth_time.minute  = os.date("%M", time); 
    earth_time.second = os.date("%S", time); 
    earth_time.weekday = os.date("%A", time); 
    earth_time.month_name = os.date("%B", time);

  return earth_time;
end

function get_next_departure_delay(vana_seconds_in_day, times, max_departures)
    local delay = 0;
    if (vana_seconds_in_day > times[max_departures]) then
        delay = (86400 - vana_seconds_in_day) + times[1];
    else
        for key, value in pairs(times) do
            if(value > vana_seconds_in_day) then
                delay = value - vana_seconds_in_day;
                return delay;
            end
        end
    end
    return delay;
end

function convert_vanaseconds_to_earthseconds(vanaseconds)
    return math.floor(vanaseconds * 0.04);
end

function convert_earthseconds_to_vanaseconds(earthseconds)
    return earthseconds * 25;
end

function time_to_string(seconds)
    local time = ""

    if(seconds < 60) then
        time = tostring(seconds) .. " seconds";
    else
        time = tostring(math.floor(seconds / 60)) .. " minutes";
    end

    return time;
end

function get_next_RSE_start_time(race)
    local current_vanatime = (ashita.ffxi.vanatime.get_raw_timestamp() + 92514960) * 25;
    local RSE_mod = math.floor(current_vanatime / (8 * 691200)) * (8 * 691200);
    RSE_mod = RSE_mod + ((race - 1) * 691200);
    
    if(current_vanatime > (RSE_mod + 691200)) then
        RSE_mod = RSE_mod + (8 * 691200);
    end
    
    return get_earth_time(math.floor(RSE_mod / 25) - 92514960);
end

function get_next_RSE_end_time(race)
    local current_vanatime = (ashita.ffxi.vanatime.get_raw_timestamp() + 92514960) * 25;
    local RSE_mod = math.floor(current_vanatime / (8 * 691200)) * (8 * 691200);
    RSE_mod = RSE_mod + ((race - 1)  * 691200);
    
    if(current_vanatime > (RSE_mod + 691200)) then
        RSE_mod = RSE_mod + (8 * 691200);
    end

    return get_earth_time(math.floor((RSE_mod + 691200) / 25) - 92514960);
end

function get_next_RSE_location(race)
    local location = 0;
    local current_vanatime = (ashita.ffxi.vanatime.get_raw_timestamp() + 92514960) * 25;
    local RSE_mod = math.floor(current_vanatime / (8 * 691200)) * (8 * 691200);
    RSE_mod = RSE_mod + ((race - 1)  * 691200);
    
    if(current_vanatime > (RSE_mod + 691200)) then
        RSE_mod = RSE_mod + (8 * 691200);
    end
    RSE_mod = RSE_mod + (8 * 691200);
    return (math.floor(RSE_mod / 691200) % 3) + 1;
end

function get_next_moon_phase()
    local mphase = (math.floor(((ashita.ffxi.vanatime.get_raw_timestamp() + 92514960) * 25) / 86400) + 26) % 84;
    local current_phase = ashita.ffxi.vanatime.get_current_date().moon_phase + 1;
    local next_phase = current_phase + 1;
    if (next_phase == 3 or next_phase == 6 or next_phase == 9) then
        next_phase = next_phase + 1;
    elseif (next_phase == 12) then
        next_phase = 1;
    end

    local diff = 0;
    if(MoonPhaseChanges[next_phase] < mphase) then
        diff = (84 - mphase) + MoonPhaseChanges[next_phase];
    else
        diff = MoonPhaseChanges[next_phase] - mphase;
    end

    local start_of_vanaday = math.floor(ashita.ffxi.vanatime.get_current_second()) + (60 * math.floor(ashita.ffxi.vanatime.get_current_minute())) + (3600 * math.floor(ashita.ffxi.vanatime.get_current_hour()));
    local vanatimediff = (3456 * diff * 25) - start_of_vanaday;
    
    return get_earth_time(os.time() + (vanatimediff/25))
end