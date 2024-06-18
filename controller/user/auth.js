const jwt = require("jsonwebtoken");
const Auth = require("../../db/user")


const signup = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const user = await Auth.createAccount( { username, email, password } );

    if (user) {
      return login(req, res)
    } else {
      return res.status(409).json({ error : "Error signup" })
    }
  } catch (error) {
    return res.status(409).json({ error : error })
  }
};


//login authentication

const login = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const user = await Auth.getAccountInfo( { username, email } )
    console.log(user)
    const isSame = await Auth.comparePwd(password, user.password);

    if (isSame) {
      // Only sign username and email (no)
      let token = jwt.sign( {"user" : { "user_id": user.user_id,"username" : user.username, "email" : user.email }}, process.env.secretKey, {
        expiresIn: 1 * 24 * 60 * 60 * 1000,
      });

      res.cookie("user", { "user_id": user.user_id, "username" : user.username, "email" : user.email }, { 
        maxAge: 1 * 24 * 60 * 60, 
        httpOnly: true,
        // secure: process.env.NODE_ENV === "production"
      });

      console.log("user", JSON.stringify(user, null, 2));
      console.log(token);
      
      return res.status(201).send({
        "userName": user.username,
        "token": token,
        "email": user.email,
        "user_id": user.user_id
      });


    } else {
      return res.status(401).send("Authentication failed");
    }
  } catch (error) {
    console.log(error);
    return res.status(401).json({ "error" : error });
  }
};

const signout = (req, res, next) => {
  res.clearCookie('user');
  return res.status(200).send("Sign out successfullly")
}


module.exports = {
 signup,
 login,
 signout,
};