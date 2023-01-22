VanaDay         = T{"Firesday", "Earthsday", "Watersday", "Windsday", "Iceday", "Lightningday", "Lightsday", "Darksday"};
DayColor        = T{{0.87, 0.0, 0.0, 1.0}, {0.67, 0.67, 0.0, 1.0}, {0.0, 0.0, 0.87, 1.0}, {0.0, 0.67, 0.13, 1.0}, {0.47, 0.6, 1.0, 1.0}, {0.67, 0.0, 0.67, 1.0}, {0.67, 0.67, 0.67, 1.0}, {0.2, 0.2, 0.2, 1.0}};
MoonPhase       = T{"New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"};

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
        
        mhaura_to_aht_urhgan = T { },
        aht_urhgan_to_mhaura = T { },
        aht_urhgan_to_nashmau = T { },
        nashmau_to_aht_urhgan = T { },

        bibiki_bay_to_purgonorgo_isle = T { },
        purgonorgo_isle_to_bibiki_bay = T { },
    },

    
    -- Background Primitive Settings
    background = T{
        visible = true,
        color = 0x80000000,
        can_focus = false,
        locked = true,
    },
};