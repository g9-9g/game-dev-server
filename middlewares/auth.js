const express = require("express");
const db = require("../model");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");


const checkUser = async (req, res, next) => {
    try {
        var name = req.body.userName
        var email = req.body.email
        var password = req.body.password
        
        const nameRegex = /^[a-zA-Z][a-zA-Z0-9_-]{2,19}$/
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\S]{8,}$/
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

        if (!(nameRegex.test(name) && passwordRegex.test(password) && emailRegex.test(email))) {
            return res.json(409).send("invalid name or passwordor email");
        }

        var count_name = await db.query(`SELECT * FROM "users" WHERE username = $1 `, [name]).rowCount
        
        console.log(count_name)
        // if username exist in the database respond with a status of 409
        if (count_name > 0) {
            return res.json(409).send("username already taken");
        }
        
        //checking if email already exist
        var count_email = await db.query(`SELECT * FROM "users" WHERE email = $1 `, [email]).rowCount
        console.log(count_email)
        //if email exist in the database respond with a status of 409
        if (count_email > 0) {
            return res.json(409).send("Authentication failed");
        }
    
    next();
    } catch (error) {
        console.log(error);
    }
}

const checkToken = async (req, res, next) => {
    try {
        const token = req.headers.authorization.split(' ')[1];
        const decodedToken = jwt.verify(token, 'RANDOM_TOKEN_SECRET');
        const userId = decodedToken.userId;
    if (req.body.userId && req.body.userId !== userId) {
        throw 'Invalid user ID';
    } else {
        next();
    }
    } catch {
        res.status(401).json({
        error: new Error('Invalid request!')
    });
    }
}

module.exports = {
    checkUser,
    checkToken

}