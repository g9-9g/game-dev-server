const db = require("./index");


const filter_fields = ["character_name", "character_class"];
const sort_fields = ["character_name", "character_class", "characters_level"];

const consolidateChars = (characters) => {
    const charactersMap = new Map();
    characters.forEach(character => {
        const { character_id, character_name, chars_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id, skill_id, skill_name, level_req, selected_skill } = character;
        if (!charactersMap.has(character_id)) {
            charactersMap.set(character_id, {
                character_id, character_name, chars_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id,
                skills: []
            });
        }
        if (chars_level >= 0) {
            const charactersEntry = charactersMap.get(character_id);
            charactersEntry.skills.push({
                skill_id, skill_name, level_req, selected_skill
            });
        }
    });
    return Array.from(charactersMap.values());
}

const searchCharName = async (user_id, query_name, sort_option) => {
    var sql_query = `SELECT 
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
    ( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = $1 ) as ownedChar 
    ON ownedChar.character_id = characters.character_id
    WHERE character_name ILIKE $2`;
    params_arr = [user_id, `${query_name}%`];
    sql_query += db.sortSQL(sort_fields, sort_option);

    // console.log(sql_query)

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error");
    }
}

const filterChar = async (user_id, filter, sort_option) => {
    var sql_query = `
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
    ( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = $1 ) as ownedChar 
    ON ownedChar.character_id = characters.character_id`;
    var params_arr = [user_id];

    var cnt = 0;
    var filterKey = Object.keys(filter).filter((key) => (filter_fields.includes(key)))
    for (var i = 0;i < filterKey.length;i++) {
        var key = filterKey[i];
        if (filter[key] && Array.isArray(filter[key]) && filter[key] != 0) {
            sql_query += ((cnt==0) ? ' WHERE ' : ' AND ') + key + ' IN (';
            filter[key].forEach((value,index) => {
                sql_query += ((index == 0) ? '' : ',') + '$' + (params_arr.length + 1);
                params_arr.push(value);
            });
            sql_query += ')';
            cnt++;
        }
    }

    sql_query += db.sortSQL(sort_fields, sort_option);

    console.log(sql_query);
    console.log(params_arr);

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("No character found!");
    }
}

const getAllCharAndSkillSet = async (user_id, query_name, filter, sort_option) => {
    sql_query = `
        SELECT
            characters.character_id, 
            character_name,
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
        ( SELECT character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id FROM user_char WHERE user_id = $1 ) as ownedChar
        JOIN skills ON skills.character_id = ownedChar.character_id
        ) as owned_char ON characters.character_id = owned_char.character_id
        WHERE character_name ILIKE $2`
    params_arr = [user_id, `${query_name}%`]

    var cnt = 0;
    var filterKey = Object.keys(filter).filter((key) => (filter_fields.includes(key)))
    for (var i = 0;i < filterKey.length;i++) {
        var key = filterKey[i];
        if (filter[key] && Array.isArray(filter[key]) && filter[key] != 0) {
            sql_query += ' AND ' + key + ' IN (';
            filter[key].forEach((value,index) => {
                sql_query += ((index == 0) ? '' : ',') + '$' + (params_arr.length + 1);
                params_arr.push(value);
            });
            sql_query += ')';
            cnt++;
        }
    }

    sql_query += db.sortSQL(sort_fields, sort_option);

    console.log(sql_query);
    console.log(params_arr);

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return consolidateChars(res.rows);
    } else {
        throw new Error("No character found!");
    }
}


// Sample function
const getOwnedCharacters = async (user_id, query, sort_option) => {
    var sql_query = `
    SELECT *
    FROM user_char 
    JOIN characters ON user_char.character_id = characters.character_id
    WHERE user_char.user_id = $1`;
    var params_arr = [user_id];

    // Filter
    var filterKey = Object.keys(query).filter((key) => (filter_fields.includes(key)))
    for (var i = 0;i < filterKey.length;i++) {
        var key = filterKey[i];
        if (query[key]) {
            sql_query += ' AND ' + key + ' ILIKE $' + (params_arr.length + 1);
            params_arr.push(`%${query[key]}%`);
        }
    }
    console.log(sql_query);
    console.log(params_arr);

    // Sort
    var sortKey = Object.keys(sort_option).filter((key) => (sort_fields.includes(key)))
    var cnt = 0;
    for (var i = 0;i < sortKey.length;i++) {
        var key = sortKey[i];
        if (sort_option[key] == 'ASC' || sort_option[key] == 'DESC') {
            sql_query += (cnt > 0) ? ',' : '\nORDER BY ' + key + ' ' + sort_option[key];
            cnt++;
        }
    }
    console.log(sql_query);
    console.log(params_arr);

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("No character found!");
    }
}

const unlockCharacter = async (user_id, char_id) => {
    var sql_query = `
    INSERT INTO user_char (user_id, character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id)
                    VALUES ($1, $2, 0,1,1,1,1,1)
    `;
    var params_arr = [user_id, char_id];
    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res;
    } else {
        throw new Error("No character found!");
    }
}


const updateStateCharacter = async (user_id, char_id, new_state) => {
    const allow_update_fields = []
    var sql_query = `
        UPDATE user_char
        SET
    `;
    var params_arr = [char_id, user_id];

    Object.keys(new_state).filter((key) => (allow_update_fields.includes(key))).forEach((key) => {
        if (new_state[key] != null) {
            sql_query += ' ' + key + ' = ' + '$' +  (params_arr.length + 1);
            params_arr.push(new_state[key]);
        }
    })

    if (params_arr.length <= 2) {
        throw new Error("Invalid update fields or values");
    }

    sql_query += 'WHERE character_id = $1 AND user_id = $2'
    console.log(sql_query);

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res;
    } else {
        throw new Error("No character found!");
    }

}

const createCharacter = async (character) => {
    const { name, character_class, base_hp, base_atk, base_def, multiplier } = character

    var res = await db.query(`INSERT INTO characters(character_name, character_class, base_hp, base_def, base_atk, multiplier)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING character_id, character_name AS name, character_class, base_hp, base_def, multiplier`,  [name, character_class, base_hp, base_atk, base_def, multiplier]);
    if (res) {
        var result = res.rows[0];
        result.skills = [];    
        // console.log(result)

        var character_id = res.rows[0].character_id;
        var sql_query = `INSERT INTO skills (character_id, skill_name, level_req)
                        VALUES`;
        var params_arr = [character_id];
        character.skills.forEach((skill, index) => {
            sql_query += ((index == 0) ? '(' : ',(') + '$1,' + `$${params_arr.length + 1},` + `$${params_arr.length + 2})`
            params_arr.push(skill.skill_name);
            params_arr.push(skill.level_req || 0);
        })
        sql_query += ` RETURNING skill_id, skill_name, level_req`
        var res2 = await db.query(sql_query, params_arr);
        if (res2) {
            res2.rows.forEach((skill) => result.skills.push(skill));
            return result;
        } else {
            throw new Error("No character found!");
        }
    } else {
        throw new Error("No character found!");
    }
}

// Error
const createCharacterv2 = async (character) => {
    const { name, character_class, base_hp, base_atk, base_def, multiplier } = character

    var sql_query = `DO $$
    DECLARE
        char_id INT := 0;
    BEGIN
        INSERT INTO characters(character_name, character_class, base_hp, base_def, base_atk, multiplier)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING character_id INTO char_id;
    
        INSERT INTO skills(character_id, skill_name, level_req)
        VALUES `
    
    var params_arr = [name, character_class, base_hp, base_atk, base_def, multiplier]

    character.skills.forEach((skill, index) => {
        sql_query += ((index == 0) ? '(' : ',(') + 'char_id,' + `$${params_arr.length + 1},` + `$${params_arr.length + 2})`
        params_arr.push(skill.skill_name);
        params_arr.push(skill.level_req || 0);
    })
    sql_query += `;\nEND $$;`

    console.log(sql_query, params_arr);
    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res;
    } else {
        throw new Error("No character found!");
    }
}

const updateCharacter = async (character_id, new_character) => {
    const allow_update_fields = []
    var sql_query = `
        UPDATE characters
        SET
    `;
    var params_arr = [character_id];

    Object.keys(new_character).filter((key) => (update_fields.includes(key))).forEach((key) => {
        if (new_character[key] != null) {
            sql_query += ' ' + key + ' = ' + '$' +  (params_arr.length + 1);
            params_arr.push(new_character[key]);
        }
    })

    if (params_arr.length <= 1) {
        throw new Error("Invalid update fields or values");
    }

    sql_query += 'WHERE character_id = $1'
    console.log(sql_query);

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res;
    } else {
        throw new Error("No character found!");
    }
}

module.exports = {
    getOwnedCharacters,
    searchCharName,
    filterChar,
    unlockCharacter,
    updateStateCharacter,
    getAllCharAndSkillSet,
    createCharacter,
    updateCharacter,
}