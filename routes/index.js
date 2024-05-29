var express = require('express');
var router = express.Router();

/* GET home page. */
// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Express' });
// });
var middlewares = require('../middlewares/auth.')
var Game = require("../controller/game/read.controller");
const { getOwnedCharacters, searchCharName, filterChar } = require('../db/characters/read');

router.use('/getUserInfo/:id', [middlewares.checkToken, Game.getUserInfo]);

router.use('/getCharacters/:id/', async (req,res,next) => {
    const userId = req.params.id
    console.log(userId)
    const query = req.query;
    console.log(query);

    const result = await getOwnedCharacters(userId, query, {'character_name': 'DESC'})
    res.status(201).send({"result": result});
});

router.use('/characters/:id/search', async (req,res,next) => {
    const userId = req.params.id;
    const query_name = req.query.name;
    const sort_option = JSON.parse(req.query.sort_option);

    console.log(query_name , sort_option);

    const result = await searchCharName(userId, query_name, sort_option);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use('/characters/:id/filter', async (req,res,next) => {
    const userId = req.params.id;
    const filter = JSON.parse(req.query.filter);
    const sort_option = JSON.parse(req.query.sort_option);

    console.log(filter , sort_option);

    const result = await filterChar(userId, filter, sort_option);
    console.log(result)
    res.status(201).send({"result": result});
})

module.exports = router;