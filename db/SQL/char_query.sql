-- Hiển thị các nhân vật mà người chơi sở hữu, sort theo class
SELECT * 
FROM user_char JOIN characters ON user_char.character_id = characters.character_id
WHERE user_char.user_id = 1
ORDER BY (characters.character_class) ASC

-- Sort by level
SELECT * 
FROM user_char JOIN characters ON user_char.character_id = characters.character_id
WHERE user_char.user_id = 1
ORDER BY (user_char.characters_level) ASC




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