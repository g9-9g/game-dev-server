const db = require("./index");

const showFriendList = async (user_id, page_option) => {
    const { page_num, max_page } = page_option
    var sql_query = `
        SELECT user_id, email, username, point, level, exp
        FROM users WHERE friend_status($1, user_id) = 2
        ORDER BY (username, level)
        LIMIT $2 OFFSET $3
    `
    var params_arr = [user_id, max_page, (page_num - 1) * max_page];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error connected to database");
    }
}

const showFriendRequestList = async (user_id, page_option) => {
    const { page_num, max_page } = page_option
    var sql_query = `
    SELECT user_id, email, username, point, level, exp
    FROM users WHERE friend_status(user_id, $1) = 1
    ORDER BY (username, level)
    LIMIT $2 OFFSET $3
    `
    var params_arr = [user_id, max_page, (page_num - 1) * max_page];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error connected to database");
    }
}

const addFriend = async (user_id, friend_id) => {
    var sql_query = `INSERT INTO friends (user_id, friend_id) VALUES ($1, $2)
    RETURNING friend_id`

    var params_arr = [user_id, friend_id];

    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows[0];
    } else {
        throw new Error("Error connected to database");
    }
}

const searchUserById = async (search_id) => {
    var sql_query = `SELECT user_id, email, username, point, level, exp
        FROM users WHERE user_id = $1`
    var res = await db.query(sql_query, [search_id]);
    if (res) {
        return res.rows[0];
    } else {
        throw new Error("Error connected to database");
    }
}

// User delete (rejected friend request) from user2
const removeFriendRequest = async (user_id, user2_id) => {
    var sql_query = `DELETE FROM friends WHERE friend_id = $1 AND user_id = $2 AND friend_status($2, $1) = 1
    RETURNING user_id, friend_id`
    var params_arr = [user_id, user2_id]
    var res = await db.query(sql_query, params_arr);
    console.log(res)
    if (res) {
        return res.rows[0];
    } else {
        throw new Error("Error connected to database");
    }
}

const removeFriend = async (user_id, friend_id) => {
    var sql_query = `DELETE FROM friends WHERE (friend_id = $1 AND user_id = $2) OR (friend_id = $2 AND user_id = $1) AND friend_status($1,$2) = 2
    RETURNING friend_id`
    var params_arr = [user_id, friend_id]
    var res = await db.query(sql_query, params_arr);

    if (res) {
        return res.rows.length;
    } else {
        throw new Error("Error connected to database");
    } 
}

const searchUserByName = async (query_name, user_level, page_option) => {
    const { page_num, max_page } = page_option
    var sql_query = `SELECT user_id, email, username, point, level, exp
    FROM users
    WHERE username ILIKE $1
    ORDER BY (abs(level - $2), level)
    LIMIT $3 OFFSET $4`
    var params_arr = [`${query_name}%`, user_level, max_page, (page_num - 1) * max_page]
    var res = await db.query(sql_query, params_arr);
    if (res) {
        return res.rows;
    } else {
        throw new Error("Error connected to database");
    }
}

module.exports = {
    showFriendList,
    showFriendRequestList,
    addFriend,
    searchUserById,
    searchUserByName,
    removeFriend,
    removeFriendRequest

}