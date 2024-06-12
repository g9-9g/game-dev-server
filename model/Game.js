class Skill {


}

class Character {
    character_id;
    character_name;
    character_level;
    character_class;
    base_hp;
    base_def;
    base_atk;
    multiplier;
    weapon_id;
    skills = [];
    // CONST
    #allow_filter_fields = ["character_class"]
    #allow_sort_fields = ["character_name", "character_class", "characters_level"]

    static consolidate = (sql_response) => {
        const charactersMap = new Map();
        sql_response.forEach(character => {
            var obj = new Character(character)
            console.log(obj);
            const { character_id, character_name, character_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id, skill_id, skill_name, level_req, selected_skill } = character;
            if (!charactersMap.has(character_id)) {
                charactersMap.set(character_id, {
                    character_id, character_name, character_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id,
                    skills: []
                });
            }
            if (character_level >= 0) {
                const charactersEntry = charactersMap.get(character_id);
                charactersEntry.skills.push({
                    skill_id, skill_name, level_req, selected_skill
                });
            }
        });
        return Array.from(charactersMap.values());
    }
    static sortOPT = (sql_response) => {

    }
}

class Weapon {


}

class Effect {

}

module.exports = {
    Character, 
    Skill
}