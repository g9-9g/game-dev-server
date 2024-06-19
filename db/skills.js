const db = require("./index");
const { Skill,Effect } = require("../model/Game")


const getSkillSet = async (character_id) => {
    var sql_query = `
    SELECT * FROM skills JOIN effect ON skills.skill_id = effect.object_id
    WHERE character_id = $1
    ORDER BY (level_req)`;
    params_arr = [character_id];


    var res = await db.query(sql_query, params_arr);
    if (res) {
        return Skill.consolidate(res.rows);
    } else {
        throw new Error("Error");
    }
}

const getSkillInfo = async (skill_id) => {
    var sql_query = `
    SELECT * FROM skills JOIN effect ON skills.skill_id = effect.object_id
    WHERE skill_id = $1`;
    params_arr = [skill_id];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error");
    }
}


const insertEffects = async (object_id, effects) => {
    if (!effects || !Array.isArray(effects)) {
        throw new Error("Effects must be a non-empty array")
    }

    var sql_query = `
    INSERT INTO effect(object_id, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req) 
    VALUES `

    var params_arr = [object_id]

    effects.forEach((effect, index) => {
        sql_query += ((index == 0) ? '(' : ',(') + '$1,' + `$${params_arr.length + 1},` + `$${params_arr.length + 2},` + `$${params_arr.length + 3},` + `$${params_arr.length + 4},` + `$${params_arr.length + 5})`;
        params_arr.push(effect.stunt_amount || 0)
        params_arr.push(effect.stunt_duration || 0)
        params_arr.push(effect.slow_amount || 0)
        params_arr.push(effect.slow_duration || 0)
        params_arr.push(effect.effect_req || 0)
    })

    sql_query += `RETURNING effect_id`
    console.log(sql_query);
    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error");
    }  
}

const createSkill = async (character_id, skill_name, level_req) => {
    var sql_query = `
        INSERT INTO skills (character_id, skill_name, level_req)
                    VALUES ($1, $2, $3)
        RETURNING skill_id
    `
    var params_arr = [character_id, skill_name, level_req];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error");
    }  
}

const modifySkill = async (skill_id, skill_name, level_req) => {
    var sql_query = `
        UPDATE skills
        SET skill_name = $2, level_req = $3
        WHEN skill_id = $1
    `
    var params_arr = [skill_id, skill_name, level_req];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return skill_id;
    } else {
        throw new Error("Error");
    }  
}

module.exports = {
    getSkillSet,
    getSkillInfo,
    createSkill,
    insertEffects,
    modifySkill
}