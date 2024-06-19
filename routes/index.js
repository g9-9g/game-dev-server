var express = require('express');
var router = express.Router();
const bodyParser = require('body-parser');

router.use(bodyParser.json())

/* GET home page. */
// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Express' });
// });
var middlewares = require('../middlewares/auth.')

const { getOwnedCharacters, searchCharName, filterChar, unlockCharacter, getAllCharAndSkillSet, createCharacter } = require('../db/characters.js');
const { filterWeapon } = require('../db/weapons.js');
const { createCharacters } = require('../db/admin.js');
const { createSkill, insertEffects, getSkillSet } = require('../db/skills.js');


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
    const query_name = req.query.name || "";
    const sort_option = JSON.parse(req.query.sort_option || "{}");

    console.log(query_name , sort_option);

    const result = await searchCharName(userId, query_name, sort_option);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use('/characters/:id/filter', async (req,res,next) => {
    const userId = req.params.id;
    const filter = JSON.parse(req.query.filter || "{}");
    const sort_option = JSON.parse(req.query.sort_option || "{}");

    console.log(filter , sort_option);

    const result = await filterChar(userId, filter, sort_option);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use('/weapons/:id/filter', async (req,res,next) => {
    const user_id = req.params.id;
    const filter = JSON.parse(req.query.filter || "{}");
    const sort_option = JSON.parse(req.query.sort_option || "{}");
    const query_name = req.query.name || "";

    console.log(filter , sort_option);

    const result = await filterWeapon(user_id,query_name, filter, sort_option);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use('/admin/createCharacter', async (req,res,next) => {
    const char = req.query;
    console.log(char);

    const result = await createCharacters(char);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use ('/characters/:id/unlock/:char_id', async (req, res,next) => {
    const userId = req.params.id
    const charId = req.params.char_id
    const result = await unlockCharacter(userId, charId);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use ('/createSkill', async(req, res, next) => {
    const {charID, skill_name, level_req } = req.query;
    const result = await createSkill(charID, skill_name, level_req);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use('/getSkillSet/:id', async (req,res,next) => {
    const charID = req.params.id
    const result = await getSkillSet(charID);
    console.log(result)
    res.status(201).send({"result": result});
})

router.post ('/insertEffects/:id', async (req,res,next) => {
    const object_id = req.params.id;
    const { effects }  = req.body;
    console.log(effects)
    const result = await insertEffects(object_id, effects);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use ('/getAllCharAndSkillSet/:id', async (req,res,next) => {
    const user_id = req.params.id;
    const filter = JSON.parse(req.query.filter || "{}");
    const sort_option = JSON.parse(req.query.sort_option || "{}");
    const query_name = req.query.name || "";

    const result = await getAllCharAndSkillSet(user_id,query_name, filter, sort_option);
    console.log(result)
    res.status(201).send({"result": result});
})


router.post('/createCharacter', async(req,res,next)=> {
    const {character} =  req.body;
    console.log(character)
    const result = await createCharacter(character);
    console.log(result)
    res.status(201).send({"result": result});
})

router.use('/characters', require('./character.js'))
router.use('/weapons', require('./weapons.js'))


module.exports = router;