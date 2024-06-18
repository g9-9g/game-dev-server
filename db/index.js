var pg = require('pg')
var fs = require('fs');

require('dotenv').config()

var pool = new pg.Pool({
  user: process.env.DBUSER,
  host: process.env.DBHOST,
  database: process.env.DATABASE,
  password: process.env.DBPASSWORD,
  port: process.env.DBPORT,
})

const switchPool = (newConfig) => {
  const newPool = new pg.Pool(newConfig);

  const oldPool = pool;
  pool = newPool;

  oldPool.end(err => {
    if (err) {
      console.error('Error closing old pool:', err);
    } else {
      console.log('Old pool closed');
    }
  });

  console.log('Switched to new pool');
}


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

const sortSQL = (sortKey, sort_option) => {
  if (!sort_option) return "";
  var sql = "";
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


module.exports = { 
  get_time, 
  disconnect, 
  query , 
  load_src ,
  sortSQL,
  switchPool
}