const jwt = require("jsonwebtoken");

const checkToken = async (req, res, next) => {
    const token = req.params.userId || req.body.token || req.query.token || req.headers['x-access-token'] || req.headers['authorization'];

    if (!token) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
    jwt.verify(token, process.env.secretKey, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: 'Invalid token' });
        }
        console.log(JSON.stringify(req.cookies.user), JSON.stringify(decoded.user))
        // "2-step verify"
        if (!req.cookies.user || JSON.stringify(req.cookies.user) !== JSON.stringify(decoded.user)) {
            return res.status(401).json({ message: 'Already signout'});
        }
        
        req.user = decoded.user;
        next();
    });
}


module.exports = {
    checkToken,
}