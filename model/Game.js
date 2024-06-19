class Skill {
    skill_id;
    character_id;
    skill_name;
    level_req;
    selected_skill;
    effects = []
    constructor ({ skill_id, skill_name, level_req, character_id, selected_skill }) {
        this.skill_id = skill_id
        this.skill_name = skill_name
        this.level_req = level_req
        this.character_id = character_id
        this.selected_skill = selected_skill || 0;
    }

    static consolidate = (sql_response) => {
        const skillMap = new Map();
        sql_response.forEach(skill => {
            const { skill_id, character_id, skill_name, level_req, effect_id, object_id, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req } = skill;
            if (!skillMap.has(skill_id)) {
                skillMap.set(skill_id, new Skill ({
                    skill_id,
                    character_id,
                    skill_name,
                    level_req,
                }));
            }
            const skillEntry = skillMap.get(skill_id);
            skillEntry.effects.push( new Effect ({
                effect_id,
                object_id,
                stunt_amount,
                stunt_duration,
                slow_amount,
                slow_duration,
                effect_req
            }));
        });
        return Array.from(skillMap.values());
    }
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
    static allow_filter_fields = ["character_class"]
    static allow_sort_fields = ["character_name", "character_class", "characters_level"]
    static allow_update_fields = []
    constructor ( { character_id, character_name, character_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id } ) {
        this.character_id = character_id
        this.character_name = character_name
        this.character_level = character_level
        this.character_class = character_class
        this.base_hp = base_hp
        this.base_atk = base_atk
        this.base_def = base_def
        this.multiplier = multiplier
        this.weapon_id = weapon_id

    }

    static consolidate = (sql_response) => {
        const charactersMap = new Map();
        sql_response.forEach(character => {
            const { character_id, character_name, character_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id, skill_id, skill_name, level_req, selected_skill } = character;
            if (!charactersMap.has(character_id)) {
                charactersMap.set(character_id, new Character({
                    character_id, character_name, character_level, character_class, base_hp, base_def, base_atk, multiplier, weapon_id,
                }));
            }
            if (character_level >= 0) {
                const charactersEntry = charactersMap.get(character_id);
                charactersEntry.skills.push(new Skill ({
                    skill_id, skill_name, level_req, selected_skill, character_id
                }));
            }
        });
        return Array.from(charactersMap.values());
    }
    static sortOPT = (sort_option_obj) => {
        return Object.keys(sort_option_obj).filter((key) => (this.allow_sort_fields.includes(key)))
    }
    static filterOPT = (filter_obj) => {
        return Object.keys(filter_obj).filter((key) => (this.allow_filter_fields.includes(key)))
    }
    static updateStateKey = (new_state) => {
        return Object.keys(new_state).filter((key) => (this.allow_update_fields.includes(key)))
    }
}

class Weapon {
    instance_id;
    wp_id;
    wp_name;
    wp_class;
    wp_req;
    wp_level;
    rarity;
    base_hp;
    base_def;
    base_atk;
    multiplier;
    effects = [];
    static allow_filter_fields = ["wp_class"]
    static allow_sort_fields = ["wp_name", "wq_level", "base_atk"]
    static allow_update_fields = []

    constructor ({ instance_id, wp_id, wp_name, wp_class, wp_req, wp_level, rarity, base_hp, base_def, base_atk, multiplier }) {
        this.instance_id = instance_id
        this.wp_id = wp_id
        this.wp_name = wp_name
        this.wp_class = wp_class
        this.wp_req = wp_req;
        this.wp_level = wp_level;
        this.rarity = rarity;
        this.base_hp = base_hp;
        this.base_def = base_def;
        this.base_atk = base_atk;
        this.multiplier = multiplier;
    }

    static consolidate = (sql_response) => {
        const weaponMap = new Map();
        sql_response.forEach(weapon => {
            const { instance_id,
                wp_id,
                wp_name,
                wp_class,
                wp_req,
                wp_level,
                rarity,
                base_hp,
                base_def,
                base_atk,
                multiplier,
                effect_id,
                stunt_amount,
                stunt_duration,
                slow_amount,
                slow_duration,
                effect_req } = weapon;
            if (!weaponMap.has(instance_id)) {
                weaponMap.set(instance_id, new Weapon ({
                    instance_id,
                    wp_id,
                    wp_name,
                    wp_class,
                    wp_req,
                    wp_level,
                    rarity,
                    base_hp,
                    base_def,
                    base_atk,
                    multiplier
                }));
            }
            const weaponEntry = weaponMap.get(instance_id);
            weaponEntry.effects.push(new Effect({
                effect_id,
                stunt_amount,
                stunt_duration,
                slow_amount,
                slow_duration,
                effect_req
            }));
    });
        return Array.from(weaponMap.values());
    }
    static sortOPT = (sort_option_obj) => {
        return Object.keys(sort_option_obj).filter((key) => (this.allow_sort_fields.includes(key)))
    }
    static filterOPT = (filter_obj) => {
        return Object.keys(filter_obj).filter((key) => (this.allow_filter_fields.includes(key)))
    }
    static updateStateKey = (new_state) => {
        return Object.keys(new_state).filter((key) => (this.allow_update_fields.includes(key)))
    }
} 

class Effect {
    effect_id;
    object_id;
    stunt_amount;
    stunt_duration;
    slow_amount;
    slow_duration;
    effect_req;
    constructor ({ effect_id,object_id,stunt_amount,stunt_duration,slow_amount,slow_duration, effect_req}) {
        this.effect_id = effect_id;
        this.object_id = object_id;
        this.stunt_amount = stunt_amount;
        this.stunt_duration = stunt_duration;
        this.slow_amount = slow_amount;
        this.slow_duration = slow_duration;
        this.effect_req = effect_req
    }
}

module.exports = {
    Character, 
    Skill,
    Effect,
    Weapon
}