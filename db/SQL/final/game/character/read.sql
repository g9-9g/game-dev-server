-- TÌm kiếm nhân vật theo tên, hiển thị tên nhận vật, cấp độ của nhân vật, các skill được lựa chọn và được sort theo 1 trường
-- Tất cả các nhân vật người chơi không sở hữu sẽ luôn ở cuối danh sách

SELECT 
    characters.character_id, 
    character_name,
    COALESCE(characters_level, -1) as character_level, 
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
    ( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = 1 ) as ownedChar 
    ON ownedChar.character_id = characters.character_id
    WHERE character_name ILIKE '%a'

-- Lọc tất cả các nhân vật được sở hữu bởi người chơi user_id theo 1 hoặc 1 vài trường, sắp xếp theo 1 hoặc 1 vài trường
-- Tất cả các nhân vật người chơi không sở hữu sẽ luôn ở cuối danh sách
SELECT
    characters.character_id,
    character_name,
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
    ( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = 1 ) as ownedChar
    ON ownedChar.character_id = characters.character_id WHERE character_class IN ('class1','class2', 'Caster')
    ORDER BY characters_level ASC NULLS LAST

-- Hiển thị tất cả các nhân vật và trạng thái nhân vật của người chơi có user_id = 1;
-- Trạng thái nhân vật bao gồm :
    --  vũ khí đang được chọn, 
    --  tất các skill và thông tin skill của nhân vật, số skill được chọn và không được chọn,
    --  -> Skill được Map theo character_id -> Tránh việc chạy nhiều query

SELECT
    characters.character_id, 
    character_name,
    COALESCE(characters_level, -1) as character_level, 
    character_class,
    base_hp,
    base_def,
    base_atk,
    multiplier,
    -- Will be null if not owned
    weapon_id,
    skill_id,
    skill_name,
    level_req,
    selected_skill
FROM
characters LEFT JOIN (
SELECT
skills.character_id as character_id, 
characters_level, 
weapon_id,
skill_id,
skill_name,
level_req,
((CASE WHEN skill1_id = skill_id THEN 1 ELSE 0 END) * 1 + (CASE WHEN skill2_id = skill_id THEN 1 ELSE 0 END) * 2 + (CASE WHEN skill3_id = skill_id THEN 1 ELSE 0 END) * 3 + (CASE WHEN skill4_id = skill_id THEN 1 ELSE 0 END) * 4) as selected_skill FROM
( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = 1 ) as ownedChar
JOIN skills ON skills.character_id = ownedChar.character_id
) as owned_char ON characters.character_id = owned_char.character_id
