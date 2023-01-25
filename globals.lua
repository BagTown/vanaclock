VanaDay  = T{"Firesday", "Earthsday", "Watersday", "Windsday", "Iceday", "Lightningday", "Lightsday", "Darksday"};
DayColor = T{{0.87, 0.0, 0.0, 1.0}, {0.67, 0.67, 0.0, 1.0}, {0.0, 0.0, 0.87, 1.0}, {0.0, 0.67, 0.13, 1.0}, {0.47, 0.6, 1.0, 1.0}, {0.67, 0.0, 0.67, 1.0}, {0.67, 0.67, 0.67, 1.0}, {0.2, 0.2, 0.2, 1.0}};

MoonPhase        = T{"New Moon", "Waxing Crescent", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Waning Gibbous", "Last Quarter", "Waning Crescent", "Waning Crescent"};
MoonPhaseChanges = T{   
    [1] = 38, --New Moon
    [2] = 45, --Waxing Crescent
    [4] = 59, --First Quarter
    [5] = 66, --Waxing Gibbous
    [7] = 80, --Full Moon
    [8] = 3, --Waning Gibbous
    [10] = 17, --Last Quarter
    [11] = 24 --Waning Crescent
};

Guild = T{
    alchemy = { name = "Alchemy", opens = 28800, closes = 82800, holiday = 7 },
    bonecraft = { name = "Bonecraft", opens = 28800, closes = 82800, holiday = 4 },
    clothcraft = { name = "Clothcraft", opens = 21600, closes = 75600, holiday = 1 },
    cooking = { name = "Cooking", opens = 18000, closes = 72000, holiday = 8 },
    fishing = { name = "Fishing", opens = 10800, closes = 64800, holiday = 6 },
    goldsmith = { name = "Goldsmithing", opens = 28800, closes = 82800, holiday = 5 },
    leathercraft = { name = "Leathercraft", opens = 10800, closes = 64800, holiday = 5 },
    smithing = { name = "Smithing", opens = 28800, closes = 82800, holiday = 3 },
    woodworking = { name = "Woodworking", opens = 21600, closes = 75600, holiday = 1 },
};

-- Default Settings
Default_settings = T{
    visible = T{ true, },
    opacity = T{ 1.0, },
    padding = T{ 1.0, },
    scale = T{ 0.5, },
    x = T{ 100, },
    y = T{ 100, },

    font = T{
        visible = true,
        color = 0xFFFFFFFF,
        font_family = "Tahoma",
        font_height = 10,
    },

    -- Airship Times, These are the total seconds into the current day.
    airships = T{ 
        jeuno_to_bastok = T {[1] = 15000, [2] = 36600, [3] = 58200, [4] = 79800},
        jeuno_to_sandoria = T {[1] = 4200, [2] = 25800, [3] = 47400, [4] = 69000},
        jeuno_to_windurst = T {[1] = 9600, [2] = 31200, [3] = 52800, [4] = 74400},
        jeuno_to_kazham = T {[1] = 20100, [2] = 41700, [3] = 63300, [4] = 84900},

        bastok_to_jeuno = T {[1] = 4200, [2] = 25800, [3] = 47400, [4] = 69000},
        sandoria_to_jeuno = T {[1] = 15000, [2] = 36600, [3] = 58200, [4] = 79800},
        windurst_to_jeuno = T {[1] = 20700, [2] = 42300, [3] = 63900, [4] = 85500},
        kazham_to_jeuno = T {[1] = 9600, [2] = 31200, [3] = 52800, [4] = 74400},
    },

    -- Ferry Times
    ferries = T {
        selbina_to_mhaura = T {[1] = 0, [2] = 28800, [3] = 57600},
        mhaura_to_aht_urhgan = T {[1] = 14400, [2] = 43200, [3] = 72000},
        aht_urhgan_to_nashmau = T {[1] = 0, [2] = 28800, [3] = 57600},

        bibiki_bay_to_purgonorgo_isle = T {[1] = 19800, [2] =  63000},
        purgonorgo_isle_to_bibiki_bay = T {[1] = 33300, [2] = 76500},
        bibiki_bay_maliyakaleya_reef_tour = T {[1] = 46200},
        bibiki_bay_dhalmel_rock_tour = T {[1] = 3000},
    },

    barges = T {
        north_to_central = T {[1] = 62700},
        central_to_south = T {[1] = 18600, [2] = 71400},
        south_to_north = T {[1] = 36600},
        south_to_central = T {[1] = 3000},
    },

    -- RSE Static Location Times
    RSE = {
        race = T {[1] = "M. Elvaan", [2] = "F. Elvaan", [3] = "M. Tarutaru", [4] = "F. Tarutaru", [5] = "Mithra", [6] = "Galka", [7] = "M. Hume", [8] = "F. Hume"},
        location = T {[1] = "Gusgen Mines", [2] = "Shakhrami Maze", [3] = "Ordelle\'s Caves"},
    },
    
    -- Background Primitive Settings
    background = T{
        visible = true,
        color = 0x80000000,
        can_focus = false,
        locked = true,
    },
};