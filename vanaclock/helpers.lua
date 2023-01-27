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
    earth_time.time = time;

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

function get_guild_status_time(guild)
    local vana_seconds_in_day = math.floor(ashita.ffxi.vanatime.get_current_second()) + (60 * math.floor(ashita.ffxi.vanatime.get_current_minute())) + (3600 * math.floor(ashita.ffxi.vanatime.get_current_hour()));
    local vana_day = ashita.ffxi.vanatime.get_current_date().weekday + 1;
    local guild_status = "";
    local delay = 0;

    if(guild.holiday == vana_day) then
        delay = convert_vanaseconds_to_earthseconds((86400 - vana_seconds_in_day) + guild.opens);
        guild_status = guild.name .. " - GUILD HOLIDAY (CLOSED) - Opens in: " .. time_to_string(delay);
    elseif (vana_seconds_in_day >= guild.opens and vana_seconds_in_day < guild.closes) then
        delay = convert_vanaseconds_to_earthseconds(guild.closes - vana_seconds_in_day);
        guild_status = guild.name .. " Open - Closes in: " .. time_to_string(delay);
    elseif (vana_seconds_in_day < guild.opens) then
        delay = convert_vanaseconds_to_earthseconds(guild.opens - vana_seconds_in_day);
        guild_status = guild.name .. " Closed - Opens in: " .. time_to_string(delay);
    elseif (vana_seconds_in_day > guild.closes) then
        local nextday = 0;
        if (vana_day == 8) then
            nextday = 1;
        else
            nextday = vana_day + 1;
        end

        if(guild.holiday == nextday) then
            delay = convert_vanaseconds_to_earthseconds((86400 - vana_seconds_in_day) + guild.opens + 86400);
            guild_status = guild.name .. " Closed (Holiday Tomorrow) - Opens in: " .. time_to_string(delay);
        else
            delay = convert_vanaseconds_to_earthseconds((86400 - vana_seconds_in_day) + guild.opens);
            guild_status = guild.name .. " Closed - Opens in: " .. time_to_string(delay);
        end
    end

    return guild_status;
end

function getStartOfMostRecentFullMoon()
    local now = os.time(os.date("!*t"));
    local timezoneDiff = os.time(os.date("*t")) - now;
    local moonEpoch = os.time{year = 2004, month = 1, day = 25, hour = 2, min = 31, sec = 12}; --2004-01-25 02:31:12
    local timeSinceMoonEpoch = now - moonEpoch;
    local secPerMoonCycle = 290304; --84 gamedays and 3456 seconds per gameday for full cycle

    local moonPhaseZero = now - (timeSinceMoonEpoch % secPerMoonCycle);
    local fullMoonStart = moonPhaseZero - (13824); --subtract 4 gamedays to get to start of full moon

    return fullMoonStart + timezoneDiff;
end

function getStartOfCurrentMoonPhase()
    local fullMoonStart = getStartOfMostRecentFullMoon();
    local now = os.time();
    local timeSinceStartOfFullMoon = now - fullMoonStart;

    local gamesdaysSinceStart = timeSinceStartOfFullMoon/3456;
    local timeSinceNearestPhaseStart = 3456 * (gamesdaysSinceStart % 7);
    local phaseDiff = timeSinceStartOfFullMoon - timeSinceNearestPhaseStart;
    

    local secondsIntoVanaDay = (3456 * (gamesdaysSinceStart % math.floor(timeSinceStartOfFullMoon/3456)));
    local numPhasesSinceStart = math.floor(gamesdaysSinceStart/7);


    return fullMoonStart + phaseDiff;
end

function getCurrMoonPhase()
    local fullMoonStart = getStartOfMostRecentFullMoon();
    local now = os.time();
    local timeSinceStartOfFullMoon = now - fullMoonStart;

    local gamesdaysSinceStart = timeSinceStartOfFullMoon/3456;
    local numPhasesSinceStart = math.floor(gamesdaysSinceStart/7);
    local currMoonPhase = numPhasesSinceStart + 1;
    
    return currMoonPhase;
end

function getSelectedPhaseStart(moonPhase)
    local currPhaseStart = getStartOfCurrentMoonPhase();
    local currMoonPhase = getCurrMoonPhase();
    local moonPhaseDiff = 0;
    local delay = 0;
    if(moonPhase > currMoonPhase) then
        moonPhaseDiff = moonPhase - currMoonPhase;
    elseif (currMoonPhase > moonPhase) then
        moonPhaseDiff = 12 - currMoonPhase + moonPhase;
    end
    if(moonPhaseDiff == 0) then
        return get_earth_time(currPhaseStart);
    end

    delay = moonPhaseDiff * 24192;
    return get_earth_time(currPhaseStart + delay);
end