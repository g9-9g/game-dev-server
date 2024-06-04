const db = require("./index");
const bcrypt = require("bcrypt");

const createAccount = async ( {username, email , password } ) => {
    const data = [username, email, await bcrypt.hash(password, 10)]
    const res = await db.query(
        `INSERT 
        INTO "users" (username, email, password)
        VALUES ($1, $2, $3)`, data)
    console.log(res);
    return (res.rowCount && res.rowCount > 0);
}

const getAccountInfo = async ( { username, email } ) => {
    if (email) {
        var res = await db.query(
          `SELECT user_id, username, email, password
          FROM "users" WHERE email = $1`, [email])
    } else {
        var res = await db.query(
          `SELECT user_id, username, email, password
          FROM "users" WHERE username = $1`, [username])
    }
    if (res && res.rowCount === 1) {
        return res.rows[0];
    } else {
        throw new Error("No exist account || error when fetch data from database");
    }
}

const comparePwd = async (password, hash) => {
    return await bcrypt.compare(password, hash);
}


const getAllUserInfo = async (user_id) => {
    const sql = `
        SELECT 
            users.user_id, username, email,
            COUNT(DISTINCT inventory.id) as inven_type_count,
            MAX(inventory.quantity) as inven_max_quantity,
            COUNT(chars.id) / COUNT(DISTINCT inventory.id) as char_count,
            AVG(characters_level) as avg_char_level
        FROM 
            users LEFT JOIN instance.user_char as chars 
            ON users.user_id = chars.user_id
            LEFT JOIN instance.user_item as inventory
            ON users.user_id = inventory.user_id
            GROUP BY users.user_id;
    `
    const res = await db.query(sql)
    console.log(res);

    return res;
}

module.exports = {
    createAccount,
    getAccountInfo,
    comparePwd,
    getAllUserInfo
}