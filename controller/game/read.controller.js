const Game = require("../../model/game.model")

const getUserInfo = async (req, res, next) => {
    const user_id = req.params.id || req.body.user_id
    
    try {
        const data = await Game.getAccountInfo(user_id)

        res.status(201).send(data)
    } catch (error) {
        console.log(error)
        res.status(401).send(error);
    }
    


}

module.exports = {
    getUserInfo

}
