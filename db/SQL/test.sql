SELECT
    characters.character_id, 
    COALESCE(characters_level, -1) as chars_level, 
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
( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = 2 ) as ownedChar
JOIN skills ON skills.character_id = ownedChar.character_id
) as owned_char ON characters.character_id = owned_char.character_id