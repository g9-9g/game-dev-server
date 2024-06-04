const db = require("./index");

const createCharacters = async (character) => {
    var sql_query = `
    INSERT INTO characters (character_name, character_class, base_hp, base_def, base_atk, multiplier)
                    VALUES ($1, $2, $3, $4, $5, $6)
    `;
    params_arr = [character.name, character.class, character.base_hp || 0, character.base_def || 0, character.base_atk || 0, character.multiplier || 1];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res;
    } else {
        throw new Error("Error");
    }
} 


module.exports = {
    createCharacters
}