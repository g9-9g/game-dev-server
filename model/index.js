var pg = require('pg')
var fs = require('fs');

require('dotenv').config()

const pool = new pg.Pool({
  user: process.env.DBUSER,
  host: process.env.DBHOST,
  database: process.env.DATABASE,
  password: process.env.DBPASSWORD,
  port: process.env.DBPORT,
})

const get_time = async () => {
    return await pool.query('SELECT NOW()')
}

const disconnect = async () => {
  return await pool.end()
}

const query = (text, params, callback) => {
  return pool.query(text, params, callback)
}

const load_src = async (src) => {
  var sql = fs.readFileSync(src).toString();
  return await pool.query(sql);
}

module.exports = { 
  get_time, 
  disconnect, 
  query , 
  load_src ,
}