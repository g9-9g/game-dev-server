const db = require("./index")


// read
const getUserInfo = async (user_id) => {
    
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
    getAllWeapons

}


[{  
    "stunt_amount" : 0,
    "stunt_duration"  : 1,
    "slow_amount"  : 2,
    "slow_duration"  : 3,
    "effect_req": 4,
},{
    "stunt_amount" : 10,
    "stunt_duration"  : 11,
    "slow_amount"  : 12,
    "slow_duration"  : 13,
    "effect_req": 14,
}]