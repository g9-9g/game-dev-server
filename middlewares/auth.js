const express = require("express");
const db = require("../model");
const jwt = require("jsonwebtoken");


const checkUser = async (req, res, next) => {
    try {
        console.log(req.body)
        var name = req.body.username
        var email = req.body.email
        var password = req.body.password
        
        const nameRegex = /^[a-zA-Z][a-zA-Z0-9_-]{2,19}$/
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\S]{8,}$/
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

        // if (!(nameRegex.test(name) && passwordRegex.test(password) && emailRegex.test(email))) {
        //     return res.status(409).send("invalid name or password email");
        // }
        var db_res = await db.query(`SELECT * FROM "users" WHERE username = $1`, [name])
        
        console.log(db_res.rows.length)
        // if username exist in the database respond with a status of 409
        if (db_res.rows.length > 0) {
            return res.status(409).send("username already taken");
        }
        
        //checking if email already exist
         db_res2 = await db.query(`SELECT * FROM "users" WHERE email = $1`, [email])
        console.log(db_res2)
        //if email exist in the database respond with a status of 409
        if (db_res2.rows.length > 0) {
            return res.status(409).send("Authentication failed");
        }
    
    next();
    } catch (error) {
        console.log(error);
        return res.status(409).send("dm ong dang")
    }
}

const checkToken = async (req, res, next) => {
    console.log(req.body)
    try {
        const token = req.body.token || req.query.token || req.headers['x-access-token'];
        console.log(token)
        const decodedToken = jwt.verify(token, process.env.secretKey);
        const user = decodedToken.user;
        console.log(user);
        if (req.body.user_id && req.body.user_id !== user.user_id) {
            throw 'Invalid user ID';
        } else {
            next();
        }
    } catch(error) {
        console.log(error)
        res.status(401).json({
            error: new Error('Invalid request!')
        });
    }
}

module.exports = {
    checkUser,
    checkToken
    
}