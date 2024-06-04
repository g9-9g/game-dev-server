-- Trigger to assign skill when player unlock a character

CREATE OR REPLACE FUNCTION assign_skills()
RETURNS TRIGGER AS $$
DECLARE
    skill_ids INTEGER[];
BEGIN
    -- Get 4 distinct skill_ids from the skills table
    SELECT ARRAY_AGG(skill_id) INTO skill_ids
    FROM (
        SELECT * FROM skills WHERE character_id = NEW.character_id ORDER BY (level_req) LIMIT 4
    ) sub;

    IF array_length(skill_ids, 1) < 4 THEN
        RAISE EXCEPTION 'Not enough distinct skills available';
    END IF;

    -- Insert a free default weapon 
    -- INSERT INTO 

    -- Assign these skills to the new row
    NEW.skill1_id := skill_ids[1];
    NEW.skill2_id := skill_ids[2];
    NEW.skill3_id := skill_ids[3];
    NEW.skill4_id := skill_ids[4];

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_user_char
BEFORE INSERT ON user_char
FOR EACH ROW
EXECUTE FUNCTION assign_skills();


-- Trigger to check when player change skill or weapons
CREATE OR REPLACE FUNCTION check_valid_update()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.weapon_id IS DISTINCT FROM NEW.weapon_id) THEN
        IF ( NOT EXISTS (SELECT wp_id FROM user_weapon WHERE wp_id = NEW.weapon_id AND user_id = OLD.user_id)) THEN
            RAISE EXCEPTION 'No exist weapon';
        END IF;
    END IF;

    IF (OLD.skill1_id IS DISTINCT FROM NEW.skill1_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill1_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 1';
        END IF;
    END IF;

    IF (OLD.skill2_id IS DISTINCT FROM NEW.skill2_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill2_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 2';
        END IF;
    END IF;

    IF (OLD.skill3_id IS DISTINCT FROM NEW.skill3_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill3_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 3';
        END IF;
    END IF;

    IF (OLD.skill4_id IS DISTINCT FROM NEW.skill4_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill4_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 4';
        END IF;
    END IF;

    IF ( NEW.skill1_id = NEW.skill2_id OR NEW.skill2_id = NEW.skill3_id OR NEW.skill3_id = NEW.skill4_id OR NEW.skill1_id = NEW.skill3_id OR NEW.skill2_id = NEW.skill4_id OR NEW.skill1_id = NEW.skill4_id ) THEN
        RAISE EXCEPTION '4 skills must be unique';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_valid_update_trigger
BEFORE UPDATE ON user_char
FOR EACH ROW
EXECUTE FUNCTION check_valid_update();
