-- Function to generate a random timestamp within the past year
CREATE OR REPLACE FUNCTION random_timestamp()
RETURNS TIMESTAMP AS $$
DECLARE
    random_days INT;
    random_seconds INT;
    random_time TIMESTAMP;
BEGIN
    -- Generate a random number of days between 0 and 365
    random_days := (RANDOM() * 365)::INT;
    
    -- Generate a random number of seconds within a day (0 to 86400 seconds)
    random_seconds := (RANDOM() * 86400)::INT;
    
    -- Calculate the random timestamp
    random_time := CURRENT_TIMESTAMP - (random_days || ' days')::INTERVAL - (random_seconds || ' seconds')::INTERVAL;
    
    RETURN random_time;
END;
$$ LANGUAGE plpgsql;

-- Example usage of the random_timestamp function
SELECT random_timestamp() AS random_time;

CREATE TABLE "users" (
  "user_id" SERIAL PRIMARY KEY,
  "email" varchar UNIQUE,
  "username" varchar UNIQUE,
  "password" varchar,
  "point" int DEFAULT 0,
  "level" int DEFAULT 0,
  "exp" int DEFAULT 0
);

CREATE FUNCTION are_friends(player1 int, player2 int) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM friends 
        WHERE (player_id = player1 AND friend_id = player2) 
           OR (player_id = player2 AND friend_id = player1)
    );
END;
$$ LANGUAGE plpgsql;

CREATE TABLE "user_char" (
  "id" SERIAL PRIMARY KEY,
  "user_id" SERIAL,
  "character_id" int,
  "characters_level" int DEFAULT 0,
  "weapon_id" SERIAL,
  "skill1_id" SERIAL,
  "skill2_id" SERIAL,
  "skill3_id" SERIAL,
  "skill4_id" SERIAL
);

CREATE TABLE "user_weapon" (
  "id" SERIAL PRIMARY KEY,
  "user_id" SERIAL,
  "wp_id" SERIAL,
  "wp_level" int DEFAULT 0
);

CREATE TABLE "weapons" (
  "wp_id" SERIAL PRIMARY KEY,
  "wp_name" varchar UNIQUE,
  "wp_req" int DEFAULT 0,
  "base_hp" int DEFAULT 0,
  "base_def" int DEFAULT 0,
  "base_atk" int DEFAULT 0,
  "multiplier" int DEFAULT 0
);

CREATE TABLE "characters" (
  "character_id" SERIAL PRIMARY KEY,
  "character_name" varchar UNIQUE,
  "character_class" varchar UNIQUE,
  "base_hp" int DEFAULT 0,
  "base_def" int DEFAULT 0,
  "base_atk" int DEFAULT 0,
  "multiplier" int DEFAULT 0
);

CREATE TABLE "skills" (
  "skill_id" SERIAL PRIMARY KEY,
  "character_id" SERIAL,
  "skill_name" varchar,
  "level_req" int DEFAULT 0
);

CREATE TABLE "effect" (
  "effect_id" SERIAL PRIMARY KEY,
  "object_id" SERIAL,
  "stunt_amount" int DEFAULT 0,
  "stunt_duration" int DEFAULT 0,
  "slow_amount" int DEFAULT 0,
  "slow_duration" int DEFAULT 0,
  "effect_req" int DEFAULT 0
);

CREATE TABLE "friends" (
  "user_id" SERIAL,
  "friend_id" SERIAL,
  "create_at" timestamp NOT NULL
);

ALTER TABLE "user_char" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "user_char" ADD FOREIGN KEY ("character_id") REFERENCES "characters" ("character_id");

ALTER TABLE "user_char" ADD FOREIGN KEY ("weapon_id") REFERENCES "user_weapon" ("id");

ALTER TABLE "user_char" ADD FOREIGN KEY ("skill1_id") REFERENCES "skills" ("skill_id");

ALTER TABLE "user_char" ADD FOREIGN KEY ("skill2_id") REFERENCES "skills" ("skill_id");

ALTER TABLE "user_char" ADD FOREIGN KEY ("skill3_id") REFERENCES "skills" ("skill_id");

ALTER TABLE "user_char" ADD FOREIGN KEY ("skill4_id") REFERENCES "skills" ("skill_id");

ALTER TABLE "user_weapon" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "user_weapon" ADD FOREIGN KEY ("wp_id") REFERENCES "weapons" ("wp_id");

ALTER TABLE "skills" ADD FOREIGN KEY ("character_id") REFERENCES "characters" ("character_id");

-- ALTER TABLE "effect" ADD FOREIGN KEY ("object_id") REFERENCES "skills" ("skill_id");

-- ALTER TABLE "effect" ADD FOREIGN KEY ("object_id") REFERENCES "weapons" ("wp_id");

ALTER TABLE "friends" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "friends" ADD FOREIGN KEY ("friend_id") REFERENCES "users" ("user_id");


-- Insert example users
INSERT INTO users (email, username, password, point, level, exp) VALUES 
('alice@example.com', 'alice', 'hashed_password1', 100, 5, 1500),
('bob@example.com', 'bob', 'hashed_password2', 200, 10, 3000),
('charlie@example.com', 'charlie', 'hashed_password3', 50, 3, 500);

-- Insert example characters
INSERT INTO characters (character_name, character_class, base_hp, base_def, base_atk, multiplier) VALUES 
('Warrior', 'Tank', 1000, 300, 100, 2),
('Mage', 'Caster', 600, 100, 300, 3),
('Rogue', 'DPS', 800, 200, 200, 2.5);

-- Insert example skills
INSERT INTO skills (character_id, skill_name, level_req) VALUES 
(1, 'Shield Bash', 1),
(1, 'Taunt', 5),
(2, 'Fireball', 1),
(2, 'Ice Blast', 5),
(3, 'Backstab', 1),
(3, 'Shadow Step', 5);

-- Insert example weapons
INSERT INTO weapons (wp_name, wp_req, base_hp, base_def, base_atk, multiplier) VALUES 
('Sword of Valor', 1, 50, 10, 100, 1.2),
('Staff of Wisdom', 1, 20, 5, 150, 1.5),
('Dagger of Speed', 1, 30, 8, 120, 1.3);

-- Insert example user weapons
INSERT INTO user_weapon (user_id, wp_id, wp_level) VALUES 
(1, 1, 2),
(2, 2, 1),
(3, 3, 3);

-- Insert example user characters
INSERT INTO user_char (user_id, character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id) VALUES 
(1, 1, 10, 1, 1, 2, 1, 1),
(2, 2, 8, 2, 3, 4, 1, 1),
(3, 3, 5, 3, 5, 6, 1, 1);

-- Insert example effects
INSERT INTO effect (object_id, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req) VALUES 
(1, 10, 5, 0, 0, 1),  
(2, 0, 0, 15, 10, 2), 
(3, 20, 7, 5, 5, 3),  
(4, 25, 10, 10, 10, 4); 

-- Insert example friendships

-- Insert example friendships with random timestamps
INSERT INTO friends (user_id, friend_id, create_at) VALUES 
(1, 2, random_timestamp()),
(2, 1, random_timestamp()),  -- Bidirectional friendship
(1, 3, random_timestamp()),
(3, 1, random_timestamp());

