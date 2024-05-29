-- Hiển thị các nhân vật mà người chơi sở hữu, sort theo class
SELECT user_id
FROM user_char RIGHT JOIN characters ON user_char.character_id = characters.character_id
WHERE user_char.user_id = 1
ORDER BY (characters.character_class) ASC

-- Sort by level
SELECT * 
FROM user_char JOIN characters ON user_char.character_id = characters.character_id
WHERE user_char.user_id = 1
ORDER BY (user_char.characters_level) ASC

SELECT 
    characters.character_id, 
    COALESCE(characters_level, -1) as chars_level, 
    character_class,
    base_hp,
    base_def,
    base_atk,
    multiplier,
    weapon_id,
    skill1_id,
    skill2_id,
    skill3_id,
    skill4_id
FROM characters LEFT JOIN
( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = 2 ) as ownedChar 
ON ownedChar.character_id = characters.character_id
ORDER BY characters_level DESC NULLS LAST

SELECT 
 *
 FROM weapons LEFT JOIN 
(SELECT id, wp_id, wp_level FROM user_weapon WHERE user_id = 1) AS uw ON uw.wp_id = weapons.wp_id

-- filterWeapon
SELECT 
 id as instance_id,
 wp_name,
 wp_req,
 wp_level,
base_hp,
base_def,
base_atk,
multiplier,
stunt_amount, 
stunt_duration, 
slow_amount, 
slow_duration, 
effect_req 
 FROM weapons JOIN 
(SELECT id, wp_id, wp_level, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req 
FROM user_weapon JOIN effect ON effect.object_id = id WHERE user_id = 1) AS uw ON uw.wp_id = weapons.wp_id
WHERE IN ..
ORDER BY (..)


SELECT * 
FROM user_weapon JOIN weapons ON user_weapon.wp_id = weapons.wp_id
WHERE user_weapon.user_id = 1
ORDER BY (weapons.wp_class) ASC

SELECT * 
FROM user_weapon JOIN weapons ON user_weapon.wp_id = weapons.wp_id
WHERE user_weapon.user_id = 1
ORDER BY (user_weapon.wp_level) ASC

-- Sort by level
SELECT * 
FROM user_char JOIN characters ON user_char.character_id = characters.character_id
WHERE user_char.user_id = 1
ORDER BY (user_char.characters_level) ASC

SELECT *
FROM characters
WHERE character_id IN (SELECT DISTINCT(character_id) FROM user_char WHERE user_id != 1)
ORDER BY (characters.character_class) ASC

SELECT * 
FROM user_char 
JOIN characters ON user_char.character_id = characters.character_id

WHERE user_char.user_id = 1
ORDER BY (characters.character_class) ASC

SELECT * 
FROM user_weapon JOIN weapons ON user_weapon.wp_id = weapons.wp_id
JOIN effect ON object_id = weapons.wp_id
WHERE user_char.user_id = 1 AND user_weapon.wp_id
GROUP BY (user_weapon.id)

-- All characters, add a column for owned character
SELECT *
FROM characters  
WHERE character_class = 1 OR character_name


SELECT * FROM user_char JOIN
skills as skill1 ON skill1.skill_id = skill1_id
JOIN skills as skill2 ON skill2.skill_id = skill2_id
JOIN skills as skill3 ON skill3.skill_id = skill3_id
JOIN skills as skill4 ON skill4.skill_id = skill4_id
JOIN weapons as wp ON wp.wp_id = weapon_id
WHERE user_id = 1 AND character_id = 1;