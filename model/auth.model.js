const db = require("./index");
const bcrypt = require("bcrypt");

const createAccount = async ( {username, email , password } ) => {
    const data = [username, email, await bcrypt.hash(password, 10)]
    const res = await db.query(
        `INSERT 
        INTO "users" (username, email, password)
        VALUES ($1, $2, $3)`, data)
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

module.exports = {
    createAccount,
    getAccountInfo,
    comparePwd
}