const Weapon = require ('../../db/weapons')

const unlockWeapon = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const weapon_id = req.body.weapon_id
        const result = await Weapon.unlockWeapon(user_id, weapon_id);
        console.log(result)
        res.status(201).send({"result": result});
    } catch (error) {
        res.status(400).send({"Error": error});
    }
}

const filterWeapon = async (req,res,next) => {
    try {
        const user_id = req.user.user_id
        const filter = JSON.parse(req.query.filter || "{}");
        const sort_option = JSON.parse(req.query.sort_option || "{}");
        const query_name = req.query.name || "";

        console.log(filter , sort_option);

        const result = await Weapon.filterWeapon(user_id,query_name, filter, sort_option);
        console.log(result)
        res.status(201).send({"result": result});
    } catch {
        res.status(400).send({"Error": error});
    }
}

module.exports = {
    unlockWeapon,
    filterWeapon,
}