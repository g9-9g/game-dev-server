const db = require("./index");
const { Weapon } = require("../model/Game")

const filterWeapon = async (user_id, query_name, filter, sort_option) => {
    var sql_query = `SELECT 
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
   FROM user_weapon JOIN effect ON effect.object_id = wp_id WHERE user_id = $1) AS uw ON uw.wp_id = weapons.wp_id
   WHERE wp_name ILIKE $2`;
    params_arr = [user_id, `${query_name}%`];

    var filterKey = Weapon.filterOPT(filter);
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

    sql_query += db.sortSQL(Weapon.sortOPT(sort_option), sort_option);

    console.log(sql_query)

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return Weapon.consolidate(res.rows);
    } else {
        throw new Error("Error");
    }
}

const unlockWeapon = async (user_id, weapon_id) => {
    var sql_query = `
    INSERT INTO user_weapon (user_id, weapon_id, weapon_level)
                    VALUES ($1, $2, 0)
                    RETURNING id
    `;
    var params_arr = [user_id, weapon_id];
    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows[0].id;
    } else {
        throw new Error("No character found!");
    }
}

module.exports = {
    filterWeapon,
    unlockWeapon
}