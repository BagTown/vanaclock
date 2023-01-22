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

  -- Assigns a leading zero if neccessary
  if (tonumber(earth_time.day) < 10) then earth_time.day = "0" .. earth_time.day; end
  if (tonumber(earth_time.second) < 10)  then earth_time.second  = "0" .. earth_time.second; end

  return earth_time;
end

function get_next_airship_departure_delay(vana_seconds_in_day, airship_times)
    local delay = 0;
    if (vana_seconds_in_day > airship_times[4]) then
        delay = (86400 - vana_seconds_in_day) + airship_times[1];
    else
        for key, value in pairs(airship_times) do
            if(value > vana_seconds_in_day) then
                delay = value - vana_seconds_in_day;
                return delay;
            end
        end
    end
    return delay;
end

function get_next_ferry_departure_delay(vana_seconds_in_day, ferry_times)
    local delay = 0;
    if (vana_seconds_in_day > ferry_times[3]) then
        delay = (86400 - vana_seconds_in_day) + ferry_times[1];
    else
        for key, value in pairs(ferry_times) do
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

function time_to_string(vanaseconds)
    local time = ""

    if(vanaseconds < 60) then
        time = tostring(vanaseconds) .. " seconds";
    else
        time = tostring(math.floor(vanaseconds / 60)) .. " minutes";
    end

    return time;
end