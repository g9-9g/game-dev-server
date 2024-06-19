var express = require('express');
var router = express.Router();
const bodyParser = require('body-parser');

router.use(bodyParser.json())

const GetCharacter = require('../controller/game/characters/fetchChar')
const UpdateCharacter = require('../controller/game/characters/updateChar')

var middlewares = require('../middlewares/auth.');

router.get('/search', [middlewares.checkToken, GetCharacter.searchCharacter])
router.get('/filter', [middlewares.checkToken, GetCharacter.filterCharacter])
router.get('/getAll', [middlewares.checkToken, GetCharacter.getAllCharacters])

router.post('/create', [middlewares.checkToken, UpdateCharacter.createCharacter])
router.post('/unlock', [middlewares.checkToken, UpdateCharacter.unlockCharacter])
router.post('/updateState', [middlewares.checkToken, UpdateCharacter.updateStateCharacter])
router.post('/update', [middlewares.checkToken, UpdateCharacter.updateCharacter])

module.exports = router;