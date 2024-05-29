const db = require("./index");


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

const filterWeapon = async (user_id, query_name, sort_option) => {
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

module.exports = {

}