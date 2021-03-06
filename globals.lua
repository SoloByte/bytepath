default_color = {0.95, 0.95, 0.95}
background_color = {0.06, 0.06, 0.06}
ammo_color = {0.48, 0.78, 0.64}
boost_color = {0.3, 0.76, 0.85}
hp_color = {0.94, 0.4, 0.37}
skill_point_color = {1.0, 0.77, 0.36}


default_colors = {default_color, hp_color, boost_color, ammo_color, skill_point_color}
negative_colors = {
    {1.0 - default_color[1], 1.0 - default_color[2], 1.0 - default_color[3]},
    {1.0 - hp_color[1], 1.0 - hp_color[2], 1.0 - hp_color[3]},
    {1.0 - boost_color[1], 1.0 - boost_color[2], 1.0 - boost_color[3]},
    {1.0 - ammo_color[1], 1.0 - ammo_color[2], 1.0 - ammo_color[3]},
    {1.0 - skill_point_color[1], 1.0 - skill_point_color[2], 1.0 - skill_point_color[3]},
}
all_colors = fn.append(default_colors, negative_colors)


attacks = {
    ["Neutral"] = {cooldown = 0.24, ammo = 0, abbrevation = "N", color = default_color, name = "Neutral"},
    ["Double"] = {cooldown = 0.32, ammo = 2, abbrevation = "2", color = ammo_color, name = "Double"},
    ["Triple"] = {cooldown = 0.32, ammo = 3, abbrevation = "3", color = boost_color, name = "Triple"},
    ["Spread"] = {cooldown = 0.16, ammo = 2, abbrevation = "RS", color = default_color, name = "Spread"},
    ["Rapid"] = {cooldown = 0.12, ammo = 1, abbrevation = "R", color = default_color, name = "Rapid"},
    ["Back"] = {cooldown = 0.32, ammo = 2, abbrevation = "Ba", color = skill_point_color, name = "Back"},
    ["Side"] = {cooldown = 0.32, ammo = 2, abbrevation = "Si", color = boost_color, name = "Side"},
    ["Homing"] = {cooldown = 0.56, ammo = 4, abbrevation = 'H', color = skill_point_color, name = "Homing"},
    ["Sniper"] = {cooldown = 0.5, ammo = 3, abbrevation = 'Sn', color = boost_color, name = "Sniper"},
    ["Swarm"] = {cooldown = 2.5, ammo = 15, abbrevation = 'Sw', color = skill_point_color, name = "Swarm"},
    ["Blast"] = {cooldown = 0.64, ammo = 6, abbrevation = 'W', color = default_color, name = "Blast"},
    ["Spin"] = {cooldown = 0.32, ammo = 2, abbrevation = 'Sp', color = hp_color, name = "Spin"},
    ["Flame"] = {cooldown = 0.048, ammo = 0.4, abbrevation = 'F', color = skill_point_color, name = "Flame"},
    ["Bounce"] = {cooldown = 0.32, ammo = 4, abbrevation = 'Bn', color = default_color, name = "Bounce"},
    ["2Split"] = {cooldown = 0.32, ammo = 3, abbrevation = '2S', color = ammo_color, name = "2Split"},
    ["3Split"] = {cooldown = 0.5, ammo = 5, abbrevation = '3S', color = hp_color, name = "3Split"},
    ["4Split"] = {cooldown = 0.4, ammo = 4, abbrevation = '4S', color = boost_color, name = "4Split"},
    ["Lightning"] = {cooldown = 0.25, ammo = 8, abbrevation = 'Li', color = default_color, name = "Lightning"},
    ["Explode"] = {cooldown = 0.6, ammo = 4, abbrevation = 'E', color = hp_color, name = "Explode"},
    ["Laser"] = {cooldown = 0.8, ammo = 0, abbrevation = 'La', color = hp_color, name = "Laser"}, --ammo = 6
}


SCORE_POINTS = {
    AMMO =50,
    HP = 100,
    BOOST = 150,
    SKILLPOINT = 250,
    ATTACK = 500,
    ROCK = 100,
    SHOOTER = 150,
    BIGROCK = 125,
    WAVER = 175,
    SEEKER = 200,
}