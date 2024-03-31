var express = require('express');
var router = express.Router();

/* GET home page. */
// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Express' });
// });
var middlewares = require('../middlewares/auth.')
var Game = require("../controller/game/read.controller")

router.use('/getUserInfo/:id', [middlewares.checkToken, Game.getUserInfo]);

module.exports = router;