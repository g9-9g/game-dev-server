const db = require("../index");


// read
const getUserInfo = async (user_id) => {
    
}

const query_type = ["character_name", "character_class"];
const sort_fields = ["character_name", "character_class", "characters_level"];

const sortSQL = (sort_fields, sort_option) => {
    var sql = "";
    var sortKey = Object.keys(sort_option).filter((key) => (sort_fields.includes(key)))
    var cnt = 0;
    for (var i = 0;i < sortKey.length;i++) {
        var key = sortKey[i];
        if (sort_option[key] == 'ASC' || sort_option[key] == 'DESC') {
            sql += (cnt > 0) ? ',' : '\nORDER BY ' + key + ' ' + sort_option[key] + ' NULLS LAST';
            cnt++;
        }
    }
    return sql;
}

const searchCharName = async (user_id, query_name, sort_option) => {
    var sql_query = `SELECT 
        characters.character_id, 
        character_name,
        COALESCE(characters_level, -1) as char_level, 
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
    sql_query += sortSQL(sort_fields, sort_option);

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
    var filterKey = Object.keys(filter).filter((key) => (query_type.includes(key)))
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

    sql_query += sortSQL(sort_fields, sort_option);

    console.log(sql_query);
    console.log(params_arr);

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("No character found!");
    }
}

// const getAllSkill = async (user_id, character_id, )


const getOwnedCharacters = async (user_id, query, sort_option) => {
    var sql_query = `
    SELECT *
    FROM user_char 
    JOIN characters ON user_char.character_id = characters.character_id
    WHERE user_char.user_id = $1`;
    var params_arr = [user_id];

    // Filter
    var filterKey = Object.keys(query).filter((key) => (query_type.includes(key)))
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


const getAllCharacters = async (user_id) => {
    var res = await db.query(
        `SELECT * FROM characters 
        JOIN weapons ON characters.current_weapon_id = weapons.weapon_id
        WHERE user_id = $1`, [user_id]);
    if (res) {
        return res.rows;
    } else {
        throw new Error("No exist account || error when fetch data from database");
    }
}

const getAllWeapons = async (user_id) => {
    var res = await db.query(
        `SELECT * FROM weapons 
        WHERE user_id = $1`, [user_id]);
    if (res) {
        return res.rows;
    } else {
        throw new Error("No exist account || error when fetch data from database");
    }
}

const changeWeapons = async (user_id, char_id, weapon_id) => {
    var res = await db.query(
        `SELECT * FROM weapons 
        WHERE user_id = $1`, [user_id]);
}

module.exports = {
    getAllCharacters,
    getAllWeapons,
    getOwnedCharacters,
    searchCharName,
    filterChar

}