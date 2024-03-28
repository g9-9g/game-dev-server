const express = require("express");
const db = require("../model");
const jwt = require("jsonwebtoken");


const checkUser = async (req, res, next) => {
    try {
        const { username, email } = req.body

        var db_res = await db.query(`SELECT * FROM "users" WHERE username = $1`, [username])
        var db_res2 = await db.query(`SELECT * FROM "users" WHERE email = $1`, [email])

        console.log(db_res)

        if (db_res.rows.length > 0) {
            return res.status(409).send("username has already taken");
        }
        if (db_res2.rows.length > 0) {
            return res.status(409).send("email has already taken");
        }
    
        return next();
    } catch (error) {
        console.log(error)
        return res.status(409).send("Can not create account")
    }
}

const checkToken = async (req, res, next) => {
    const token = req.body.token || req.query.token || req.headers['x-access-token'] || req.headers['authorization'];

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
    checkUser,
    checkToken
    
}