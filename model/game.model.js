const db = require("./index")


// read
const getAccountInfo = async (user_id) => {
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
    getAccountInfo,

}