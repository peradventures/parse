c_chat = 158
Show_Error = false
Show_Warning = false

-- Regular Colors
c_white        = '\\cs(255,255,255)'
c_red          = '\\cs(255,0,0)'
c_orange       = '\\cs(255,146,3)'
c_red          = '\\cs(255,0,0)'
c_green        = '\\cs(39,238,17)'
c_yellow       = '\\cs(255,198,0)'
c_bright_green = '\\cs(3,252,3)'

-- Used to cycle through party nodes with a for loop.
pt = {
    [0] = 'p0',
    [1] = 'p1',
    [2] = 'p2',
    [3] = 'p3',
    [4] = 'p4',
    [5] = 'p5',
}

pt2 = {
    [0] = 'a10',
    [1] = 'a11',
    [2] = 'a12',
    [3] = 'a13',
    [4] = 'a14',
    [5] = 'a15',
}

pt3 = {
    [0] = 'a20',
    [1] = 'a21',
    [2] = 'a22',
    [3] = 'a23',
    [4] = 'a24',
    [5] = 'a25',
}

Skillchain_List = {
    [229] = 'DRG Jump Effect',
    [288] = 'Light',       [289] = 'Darkness', 
    [290] = 'Gravitation', [291] = 'Fragmentation', [292] = 'Distortion', [293] = 'Fusion',
    [294] = 'Compression', [295] = 'Liquefaction',  [296] = 'Induration', [297] = 'Reverberation', 
    [298] = 'Transfixion', [299] = 'Scission',      [300] = 'Detonation', [301] = 'Impaction',
    [385] = 'Light',       [386] = 'Darkness',
    [767] = 'Radiance',    [768] = 'Umbra'
}

ability_filter = {
    ['Phototrophic Wrath'] = true,  -- 190
    ['Sonic Boom'] = true           -- 294
}

-- monster_ability.lua doesn't have these nodes
mob_ability_filter = {
    [2954] = true,  -- Apex Cracklaw Melee
    [2955] = true,  -- Apex Cracklaw Melee
    [2956] = true,  -- Apex Cracklaw Melee
    [2959] = true,  -- Apex Cracklaw Melee
    [2960] = true,  -- Apex Cracklaw Melee
    [4166] = true,  -- Lady Lilith; Normal mode - first form ???
    [4189] = true,  -- Lady Lilith; Petaline Tempest
    [4190] = true,  -- Lady Lilith; Durance Whip
    [4191] = true,  -- Lady Lilith; Subjugating Slash
    [4192] = true,  -- Lady Lilith; Normal mode - first form ???
    [4193] = true,  -- Lady Lilith; Moonlight Veil
    [4205] = true,  -- Lady Lilith; Left handed melee with wing flare
    [4206] = true,  -- Lady Lilith; Left handed melee with reach out
    [4207] = true   -- Lady Lilith; Right handed melee with finger snap
}

-- weapon_skills.lua is missing some nodes
WS_Filter = {
    [260]  = {id = 260,  english = "Spirit Jump"},
    --[261]  = {id = 261,  english = "Soul Jump"},
    [293]  = {id = 293,  english = "Soul Jump"},
    [329]  = {id = 329,  english = "Intervene"},
    [3502] = {id = 3502, english = "Nott"}
}

important_buffs = {
    [33]  = {id = 33,  name = "Haste"},
    [39]  = {id = 39,  name = "Aquaveil",  spell_id = 55,  spell_name = "Aqualveil"},
    [40]  = {id = 40,  name = "Protect",   spell_id = 129, spell_name = "Protectra V"},
    [41]  = {id = 41,  name = "Shell",     spell_id = 134, spell_name = "Shellra V"},
    [42]  = {id = 42,  name = "Regen", special_handler = function_name},
    [43]  = {id = 43,  name = "Refresh"},
    [105] = {id = 105, name = "Barwater",  spell_id = 71,  spell_name = "Barwatera"},
    [113] = {id = 113, name = "Reraise",   spell_id = 848, spell_name = "Reraise IV"},
    [116] = {id = 116, name = "Phalanx"},
    [122] = {id = 122, name = "AGI Boost", spell_id = 482, spell_name = "Boost AGI"},
    [265] = {id = 265, name = "Flurry"},
    [275] = {id = 275, name = "Auspice",   spell_id = 96,  spell_name = "Auspice"},
    [432] = {id = 432, name = "Temper"},
    [596] = {id = 596, name = "Voidstorm"},
}

damage_abilities = {
    [66]  = {id = 66,  en = "Jump"},
    [67]  = {id = 67,  en = "High Jump"},
    [77]  = {id = 77,  en = "Weapon Bash"},
    [82]  = {id = 82,  en = "Chi Blast"},
    [125] = {id = 125, en = "Fire Shot"},
    [126] = {id = 126, en = "Ice Shot"},
    [127] = {id = 127, en = "Wind Shot"},
    [128] = {id = 128, en = "Earth Shot"},
    [129] = {id = 129, en = "Thunder Shot"},
    [130] = {id = 130, en = "Water Shot"},
    [131] = {id = 131, en = "Light Shot"},
    [132] = {id = 132, en = "Dark Shot"},
    [260] = {id = 260, en = "Spirit Jump"},
    [293] = {id = 293, en = "Soul Jump"},
    [550] = {id = 550, en = "Flaming Crush"},
    [598] = {id = 598, en = "Predator Claws"},
    [613] = {id = 613, en = "Blizzard IV"}
}

Healing_Spell_List = {
    [1]   = {id = 1,   en = "Cure"},
    [2]   = {id = 2,   en = "Cure II"},
    [3]   = {id = 3,   en = "Cure III"},
    [4]   = {id = 4,   en = "Cure IV"},
    [5]   = {id = 5,   en = "Cure V"},
    [6]   = {id = 6,   en = "Cure VI"},
    [7]   = {id = 7,   en = "Curaga"},
    [8]   = {id = 8,   en = "Curaga II"},
    [9]   = {id = 9,   en = "Curaga III"},
    [10]  = {id = 10,  en = "Curaga IV"},
    [11]  = {id = 11,  en = "Curaga V"},
    [593] = {id = 593, en = "Magic Fruit"},
}

enspell_elements = {
    [1] = {id = 1, en = "Fire"},
    [2] = {id = 2, en = "Blizzard"},
    [3] = {id = 3, en = "Aero"},
    [4] = {id = 4, en = "Stone"},
    [5] = {id = 5, en = "Water"},
    [6] = {id = 6, en = "Thunder"},
}

Damage_Spell_List = {
    [144] = {id = 144, en = "Fire"},
    [145] = {id = 145, en = "Fire II"},
    [146] = {id = 146, en = "Fire III"},
    [147] = {id = 147, en = "Fire IV"},
    [148] = {id = 148, en = "Fire V"},
    [149] = {id = 149, en = "Blizzard"},
    [150] = {id = 150, en = "Blizzard II"},
    [151] = {id = 151, en = "Blizzard III"},
    [152] = {id = 152, en = "Blizzard IV"},
    [153] = {id = 153, en = "Blizzard V"},
    [154] = {id = 154, en = "Aero"},
    [155] = {id = 155, en = "Aero II"},
    [156] = {id = 156, en = "Aero III"},
    [157] = {id = 157, en = "Aero IV"},
    [158] = {id = 158, en = "Aero V"},
    [159] = {id = 159, en = "Stone"},
    [160] = {id = 160, en = "Stone II"},
    [161] = {id = 161, en = "Stone III"},
    [162] = {id = 162, en = "Stone IV"},
    [163] = {id = 163, en = "Stone V"},
    [164] = {id = 164, en = "Thunder"},
    [165] = {id = 165, en = "Thunder II"},
    [166] = {id = 166, en = "Thunder III"},
    [167] = {id = 167, en = "Thunder IV"},
    [168] = {id = 168, en = "Thunder V"},
    [169] = {id = 169, en = "Water"},
    [170] = {id = 170, en = "Water II"},
    [171] = {id = 171, en = "Water III"},
    [172] = {id = 172, en = "Water IV"},
    [173] = {id = 173, en = "Water V"},
    [174] = {id = 174, en = "Firaga"},
    [175] = {id = 175, en = "Firaga II"},
    [176] = {id = 176, en = "Firaga III"},
    [177] = {id = 177, en = "Firaga IV"},
    [178] = {id = 178, en = "Firaga V"},
    [179] = {id = 179, en = "Blizzaga"},
    [180] = {id = 180, en = "Blizzaga II"},
    [181] = {id = 181, en = "Blizzaga III"},
    [182] = {id = 182, en = "Blizzaga IV"},
    [183] = {id = 183, en = "Blizzaga V"},
    [184] = {id = 184, en = "Aeroga"},
    [185] = {id = 185, en = "Aeroga II"},
    [186] = {id = 186, en = "Aeroga III"},
    [187] = {id = 187, en = "Aeroga IV"},
    [188] = {id = 188, en = "Aeroga V"},
    [189] = {id = 189, en = "Stonega"},
    [190] = {id = 190, en = "Stonega II"},
    [191] = {id = 191, en = "Stonega III"},
    [192] = {id = 192, en = "Stonega IV"},
    [193] = {id = 193, en = "Stonega V"},
    [194] = {id = 194, en = "Thundaga"},
    [195] = {id = 195, en = "Thundaga II"},
    [196] = {id = 196, en = "Thundaga III"},
    [197] = {id = 197, en = "Thundaga IV"},
    [198] = {id = 198, en = "Thundaga V"},
    [199] = {id = 199, en = "Waterga"},
    [200] = {id = 200, en = "Waterga II"},
    [201] = {id = 201, en = "Waterga III"},
    [202] = {id = 202, en = "Waterga IV"},
    [203] = {id = 203, en = "Waterga V"},
    [204] = {id = 204, en = "Flare"},
    [205] = {id = 205, en = "Flare II"},
    [206] = {id = 206, en = "Freeze"},
    [207] = {id = 207, en = "Freeze II"},
    [208] = {id = 208, en = "Tornado"},
    [209] = {id = 209, en = "Tornado II"},
    [210] = {id = 210, en = "Quake"},
    [211] = {id = 211, en = "Quake II"},
    [212] = {id = 212, en = "Burst"},
    [213] = {id = 213, en = "Burst II"},
    [214] = {id = 214, en = "Flood"},
    [215] = {id = 215, en = "Flood II"},
    [218] = {id = 218, en = "Meteor"},
    [219] = {id = 219, en = "Comet"},
    [245] = {id = 245, en = "Drain"},
    [246] = {id = 246, en = "Drain II"},
    [367] = {id = 367, en = "Death"},    
    [496] = {id = 496, en = "Firaja"},
    [497] = {id = 497, en = "Blizzaja"},
    [498] = {id = 498, en = "Aeroja"},
    [499] = {id = 499, en = "Stoneja"},
    [500] = {id = 500, en = "Thundaja"},
    [501] = {id = 501, en = "Waterja"},
    [502] = {id = 502, en = "Kaustra"},
    [503] = {id = 503, en = "Impact"},
    [708] = {id = 708, en = "Subduction"},
    [720] = {id = 720, en = "Spectral Floe"},
    [721] = {id = 721, en = "Anvil Lightning"},
    [722] = {id = 722, en = "Entomb"},
    [727] = {id = 727, en = "Silent Storm"},
    [728] = {id = 728, en = "Tenebral Crush"},
    [736] = {id = 736, en = "Thunderbolt"},
    [849] = {id = 849, en = "Fire VI"},
    [850] = {id = 850, en = "Blizzard VI"},
    [851] = {id = 851, en = "Aero VI"},
    [852] = {id = 852, en = "Stone VI"},
    [853] = {id = 853, en = "Thunder VI"},
    [854] = {id = 854, en = "Water VI"},
    [880] = {id = 880, en = "Drain III"},

    -- GEO nukes
    -- BLU nukes
    -- Ninjustsu Nukes
}

Buff_Spell_List = {

}