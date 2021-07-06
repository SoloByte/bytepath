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
    ["Neutral"] = {cooldown = 0.24, ammo = 0, abbrevation = "N", color = default_color},
    ["Double"] = {cooldown = 0.32, ammo = 2, abbrevation = "2", color = ammo_color},
    ["Triple"] = {cooldown = 0.32, ammo = 3, abbrevation = "3", color = boost_color},
    ["Spread"] = {cooldown = 0.16, ammo = 2, abbrevation = "RS", color = default_color},
    ["Rapid"] = {cooldown = 0.12, ammo = 1, abbrevation = "R", color = default_color},
    ["Back"] = {cooldown = 0.32, ammo = 2, abbrevation = "Ba", color = skill_point_color},
    ["Side"] = {cooldown = 0.32, ammo = 2, abbrevation = "Si", color = boost_color},
}