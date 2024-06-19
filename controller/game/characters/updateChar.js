const Character = require ('../../../db/characters')

const unlockCharacter = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const char_id = req.body.char_id
        const result = await Character.unlockCharacter(user_id, char_id);
        console.log(result)
        res.status(201).send({"result": result});
    } catch (error) {
        res.status(400).send({"Error": error});
    }
}

const updateStateCharacter = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const char_id = req.body.char_id
        const new_state = req.body.new 
        const result = await Character.updateStateCharacter(user_id, char_id, new_state);

        res.status(201).send({"result": result});
    } catch (error) {
        res.status(400).send({"Error": error});
    }
}


// Admin only
const createCharacter = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const new_character = req.body.character
        console.log(new_character)
        const result = await Character.createCharacter(new_character);


        console.log(result)
        res.status(201).send({"result": result});
    } catch (error) {
        console.log(error)
        res.status(400).send({"Error": error});
    }
}

const updateCharacter = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const character_id = req.user.char_id
        const new_character = req.body.character
        const result = await Character.updateCharacter(character_id,new_character);

        res.status(201).send({"result": result});
    } catch (error) {
        res.status(400).send({"Error": error});
    }
}

module.exports = {
    unlockCharacter,
    updateStateCharacter,
    createCharacter,
    updateCharacter
}