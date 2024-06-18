const Character = require ('../../../db/characters')


const searchCharacter = async (req,res, next) => {
    try {
        const user_id = req.user.user_id
        const sort_option = JSON.parse(req.query.sort_option || "{}");
        const query_name = req.query.name || "";

        const result = await Character.searchCharName(user_id, query_name, sort_option);
        res.status(201).send({"result": result});

    } catch (error) {
        res.status(400).send({"Error": error});
    }
}

const filterCharacter = async (req,res, next) => {
    try {
        const user_id = req.user.user_id
        const filter = JSON.parse(req.query.filter || "{}");
        const sort_option = JSON.parse(req.query.sort_option || "{}");

        const result = await Character.filterChar(user_id, filter, sort_option);
        res.status(201).send({"result": result});

    } catch (error) {
        res.status(400).send({"Error": error});
    }
}

const getAllCharacters = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const filter = JSON.parse(req.query.filter || "{}");
        const sort_option = JSON.parse(req.query.sort_option || "{}");
        const query_name = req.query.name || "";

        const result = await await Character.getAllCharAndSkillSet(user_id, query_name, filter, sort_option)
        res.status(201).send({"result": result});

    } catch (error) {
        res.status(400).send({"Error": error});
    }
}

module.exports = {
    searchCharacter,
    filterCharacter,
    getAllCharacters
}