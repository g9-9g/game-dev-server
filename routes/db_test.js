var express = require('express');
var router = express.Router();

const db = require("../db")

router.post('/', async (req,res,next) => {
    console.log(sql)
    try {
        var { sql } = req.body
        console.log(sql)
        const r = await db.query(sql);
        console.log(r);
        res.status(201).send(r);
    } catch (error) {
        console.log(error)
        return res.status(401).json({ "error" : error });
    }
    
})


module.exports = router;
