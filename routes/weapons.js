var express = require('express');
var router = express.Router();
const bodyParser = require('body-parser');

router.use(bodyParser.json())

const Weapon = require('../controller/game/weapons')

var middlewares = require('../middlewares/auth.');

router.get('/unlockWeapon', [middlewares.checkToken, Weapon.unlockWeapon])
router.get('/filter', [middlewares.checkToken, Weapon.filterWeapon])


module.exports = router;