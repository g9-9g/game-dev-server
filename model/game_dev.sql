CREATE SCHEMA IF NOT EXISTS "instance";

CREATE SCHEMA IF NOT EXISTS "socket";

CREATE SCHEMA IF NOT EXISTS "const";

CREATE TABLE IF NOT EXISTS "users" (
  "user_id" int PRIMARY KEY,
  "email" varchar,
  "username" varchar,
  "pwd" varchar
);

CREATE TABLE IF NOT EXISTS "users_info" (
  "user_id" int PRIMARY KEY,
  "point" int,
  "level" int,
  "exp" int,
  "mora" int,
  "primogem" int
);

CREATE TABLE IF NOT EXISTS "instance"."user_char" (
  "id" int PRIMARY KEY,
  "user_id" int,
  "character_id" int,
  "characters_level" int,
  "character_selection_skills" int[]
);

CREATE TABLE IF NOT EXISTS "instance"."user_room" (
  "id" int PRIMARY KEY,
  "room_id" int,
  "user_id" int,
  "join_time" timestamp,
  "team" int
);

CREATE TABLE IF NOT EXISTS "instance"."user_item" (
  "id" int PRIMARY KEY,
  "user_id" int,
  "item_id" int,
  "quantity" int
);

CREATE TABLE IF NOT EXISTS "socket"."rooms" (
  "room_id" int PRIMARY KEY,
  "gamemode" int,
  "average_rank" int,
  "createAt" timestamp,
  "expired" time
);

CREATE TABLE IF NOT EXISTS "const"."characters" (
  "character_id" int PRIMARY KEY,
  "character_name" varchar,
  "base_hp" int,
  "base_def" int,
  "base_atk" int,
  "multiplier" int
);

CREATE TABLE IF NOT EXISTS "const"."skills" (
  "skill_id" int PRIMARY KEY,
  "character_id" int,
  "skill_name" varchar,
  "level_req" int,
  "effect_type" int,
  "effect_amount" int
);

CREATE TABLE IF NOT EXISTS "const"."items" (
  "item_id" int PRIMARY KEY,
  "item_name" varchar,
  "effect_type" int,
  "effect_amount" int,
  "stackable" int
);

ALTER TABLE "users_info" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_char" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_char" ADD FOREIGN KEY ("character_id") REFERENCES "const"."characters" ("character_id");

ALTER TABLE "instance"."user_room" ADD FOREIGN KEY ("room_id") REFERENCES "socket"."rooms" ("room_id");

ALTER TABLE "instance"."user_room" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_item" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_item" ADD FOREIGN KEY ("item_id") REFERENCES "const"."items" ("item_id");

ALTER TABLE "const"."skills" ADD FOREIGN KEY ("character_id") REFERENCES "const"."characters" ("character_id");
