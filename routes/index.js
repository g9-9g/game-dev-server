var express = require('express');
var router = express.Router();

/* GET home page. */
// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Express' });
// });
var middlewares = require('../middlewares/auth.')
var Game = require("../controller/game/read.controller");
const { getOwnedCharacters } = require('../db/characters/read');

router.use('/getUserInfo/:id', [middlewares.checkToken, Game.getUserInfo]);

router.use('/getCharacters/:id/', async (req,res,next) => {
    const userId = req.params.id
    console.log(userId)
    const query = req.query;
    console.log(query);

    const result = await getOwnedCharacters(userId, query, {'character_name': 'DESC'})
    res.status(201).send({"result": result});
});

module.exports = router;