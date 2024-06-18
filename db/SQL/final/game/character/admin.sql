-- Nhập vào 1 object chứa thông tin của 1 nhân vật, bao gồm các kỹ năng, tạo nhân vật mới
-- VD về object
{
    "character": {
        "character_name" : "hello",
        "character_class" : "tanker",
        "base_hp": 1000,
        "base_def" : 1000,
        "base_atk": 10,
        "multiplier": 1,
        "skills": [
            {
                "skill_name": "toiyeugenshin",
                "level_req": 0
            },
            {
                "skill_name": "toiyeuhonkai",
                "level_req": 0
            },
            {
                "skill_name": ":v",
                "level_req": 0
            },
            {
                "skill_name": "lmao",
                "level_req": 0
            }
        ]

    }

}
-- Tương đương
INSERT INTO characters(character_name, character_class, base_hp, base_def, base_atk, multiplier)
        VALUES ('hello2', 'tanker', 1000, 1000, 10, 1)
        RETURNING character_id, character_name, character_class, base_hp, base_def, multiplier

    -- Với mỗi skill 
    --> 
    INSERT INTO skills (character_id, skill_name, level_req)
                        VALUES (character_id, 'jsss', 0)

-- Cập nhập nhân vật (thay đổi chỉ số,...)

-- VD: cập nhập nhân vật, thay đổi base_hp, base_def
UPDATE characters 
SET base_hp = 100, base_def = 12
WHERE character_id = 1