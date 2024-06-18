-- Get all skills and skill info from a charactacter, order by level requirement    
    
SELECT * FROM skills JOIN effect ON skills.skill_id = effect.object_id
WHERE character_id = 1
ORDER BY (level_req)

-- > Result are mapped into readable

-- Get all effects of a skill

SELECT * FROM skills JOIN effect ON skills.skill_id = effect.object_id
WHERE skill_id = 1


-- Insert effect to a skill

INSERT INTO effect(object_id, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req) 
    VALUES ()


-- Create skill

INSERT INTO skills (character_id, skill_name, level_req)
    VALUES ($1, $2, $3)
RETURNING skill_id

-- Modify skill
UPDATE skills
SET skill_name = $2, level_req = $3
WHEN skill_id = $1