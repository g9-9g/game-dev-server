
-- SELECT ALL USERS INFO

SELECT 
    users.user_id, username, email,
    COUNT(DISTINCT inventory.id) as inven_type_count,
    MAX(inventory.quantity) as inven_max_quantity,
    COUNT(chars.id) / COUNT(DISTINCT inventory.id) as char_count,
    AVG(characters_level) as avg_char_level
FROM 
    users LEFT JOIN instance.user_char as chars 
    ON users.user_id = chars.user_id
    LEFT JOIN instance.user_item as inventory
    ON users.user_id = inventory.user_id
    GROUP BY users.user_id


-- SELECT ALL CHAR (include stats)
SELECT
    *
FROM 
    users LEFT JOIN instance.user_char as instance_char
    ON users.user_id = instance_char.user_id
    JOIN const.user_char as char_info
    ON instance_char.character_id = char_info.character_id