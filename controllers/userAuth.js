const bcrypt = require("bcrypt");
const db = require("../model");
const jwt = require("jsonwebtoken");


const signup = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const data = [username, email, await bcrypt.hash(password, 10)]

    const db_res = await db.query(
    `INSERT 
    INTO "users" (username, email, password)
    VALUES ($1, $2, $3)`, data)

  if (db_res.rowCount > 0) {
    return await login(req,res);
  } else {
    return res.status(409).send("Details are not correct");
  }
  } catch (error) {
    return res.status(409).json({ error: error })
  }
};


//login authentication

const login = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    const db_res = await db.query(
    `SELECT *
    FROM "users" WHERE email = $1`, [email])

    console.log(db_res)
    
    if (db_res.rowCount > 0) {
      var user = db_res.rows[0];
      const isSame = await bcrypt.compare(password, user.password);

      if (isSame) {
        // Only sign username and email (no)
        let token = jwt.sign( {"user" : { "username" : user.username, "email" : user.email }}, process.env.secretKey, {
          expiresIn: 1 * 24 * 60 * 60 * 1000,
        });

        res.cookie("user", { "username" : user.username, "email" : user.email }, { 
          maxAge: 1 * 24 * 60 * 60, 
          httpOnly: true,
          // secure: process.env.NODE_ENV === "production"
        });

        console.log("user", JSON.stringify(user, null, 2));
        console.log(token);
        
        return res.status(201).send(token);


      } else {
        return res.status(401).send("Authentication failed");
      }
  } else {
    return res.status(401).send("Authentication failed");
  }
  } catch (error) {
    console.log(error);
  }
};

const signout = async (req, res, next) => {
  res.clearCookie('user');
  return res.status(200).send("Sign out successfullly")
}


module.exports = {
 signup,
 login,
 signout,
};