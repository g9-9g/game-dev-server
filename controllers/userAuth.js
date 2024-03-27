const bcrypt = require("bcrypt");
const db = require("../model");
const jwt = require("jsonwebtoken");


//signing a user up
//hashing users password before its saved to the database with bcrypt
const signup = async (req, res) => {
    console.log(req.body)
 try {
   const { userName, email, password } = req.body;
   const data = [userName, email, await bcrypt.hash(password, 10)]
   
   //saving the user
   const db_res = await db.query(
    `INSERT 
    INTO "users" (username, email, password)
    VALUES ($1, $2, $3)`, data)


    console.log(db_res)
   //if user details is captured
   //generate token with the user's id and the secretKey in the env file
   // set cookie with the token generated
   if (db_res.rowCount > 0) {
    return await login(req,res)
   } else {
     return res.status(409).send("Details are not correct");
   }
 } catch (error) {
   console.log(error);
 }
};


//login authentication

const login = async (req, res) => {
    try {
    const { email, password } = req.body;

   //find a user by their email
   const db_res = await db.query(
    `SELECT *
    FROM "users" WHERE email = $1`, [email])

    console.log(db_res)
    
   //if user email is found, compare password with bcrypt
   if (db_res.rowCount > 0) {
    var user = db_res.rows[0];
    console.log(user)
    const isSame = await bcrypt.compare(password, user.password);

     //if password is the same
      //generate token with the user's id and the secretKey in the env file

     if (isSame) {
       let token = jwt.sign({ id: user.user_id }, process.env.secretKey, {
         expiresIn: 1 * 24 * 60 * 60 * 1000,
       });

       //if password matches wit the one in the database
       //go ahead and generate a cookie for the user
       res.cookie("jwt", token, { maxAge: 1 * 24 * 60 * 60, httpOnly: true });
       console.log("user", JSON.stringify(user, null, 2));
       console.log(token);
       //send user data
       return res.status(201).send(user);
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

module.exports = {
 signup,
 login,
};