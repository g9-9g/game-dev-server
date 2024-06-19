-- Filter weapons: Lọc túi vũ khí mà người dùng sở hữu theo trường nhất định, hiển thị được sort theo 1 hoặc 1 vài trường nhất định

-- VD: 
SELECT 
    id as instance_id,
    weapons.wp_id,
    wp_name,
    wp_class,
    wp_req,
    wp_level,
    rarity,
    base_hp,
    base_def,
    base_atk,
    multiplier,
    effect_id,
    stunt_amount, 
    stunt_duration, 
    slow_amount, 
    slow_duration, 
    effect_req
    FROM weapons JOIN 
   (SELECT id, wp_id, wp_level, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req, effect_id
   FROM user_weapon JOIN effect ON effect.object_id = wp_id WHERE user_id = 1) AS uw ON uw.wp_id = weapons.wp_id
    WHERE rarity IN (4,5) AND wp_class IN ('Sword', 'Bow')


-- Tìm kiếm vũ khí theo tên, hiển thị cụ thể thông tin của vũ khí (các hiệu ứng mà vũ khi gây ra) 
    --  -> Effect được Map theo wp_id -> Tránh việc chạy nhiều query
SELECT 
    id as instance_id,
    weapons.wp_id,
    wp_name,
    wp_class,
    wp_req,
    wp_level,
    rarity,
    base_hp,
    base_def,
    base_atk,
    multiplier,
    effect_id,
    stunt_amount, 
    stunt_duration, 
    slow_amount, 
    slow_duration, 
    effect_req
    FROM weapons JOIN 
   (SELECT id, wp_id, wp_level, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req, effect_id
   FROM user_weapon JOIN effect ON effect.object_id = wp_id WHERE user_id = 1) AS uw ON uw.wp_id = weapons.wp_id
   WHERE wp_name ILIKE '%'


-- Unlock weapons
INSERT INTO user_weapon (user_id, weapon_id, weapon_level)
                VALUES (1, 2, 0)
                RETURNING id