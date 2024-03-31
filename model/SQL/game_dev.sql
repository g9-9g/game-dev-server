CREATE SCHEMA "instance";

CREATE SCHEMA "socket";

CREATE SCHEMA "const";

CREATE TABLE "users" (
  "user_id" int PRIMARY KEY,
  "email" varchar,
  "username" varchar UNIQUE,
  "password" varchar UNIQUE,
  "point" int,
  "level" int,
  "exp" int
);

CREATE TABLE "instance"."user_char" (
  "id" SERIAL PRIMARY KEY,
  "user_id" int,
  "character_id" int,
  "characters_level" int,
  "character_selection_skills" int[]
);

CREATE TABLE "instance"."user_room" (
  "id" int PRIMARY KEY,
  "room_id" int,
  "user_id" int,
  "join_time" timestamp,
  "team" int
);

CREATE TABLE "instance"."user_item" (
  "id" int PRIMARY KEY,
  "user_id" int,
  "item_id" int,
  "quantity" int
);

CREATE TABLE "socket"."rooms" (
  "room_id" int PRIMARY KEY,
  "gamemode" int,
  "average_rank" int,
  "createAt" timestamp,
  "expired" time
);

CREATE TABLE "const"."characters" (
  "character_id" SERIAL PRIMARY KEY,
  "character_name" varchar,
  "base_hp" int,
  "base_def" int,
  "base_atk" int,
  "multiplier" int
);

CREATE TABLE "const"."skills" (
  "skill_id" int PRIMARY KEY,
  "character_id" int,
  "skill_name" varchar,
  "level_req" int,
  "effect_type" int,
  "effect_amount" int
);

CREATE TABLE "const"."items" (
  "item_id" int PRIMARY KEY,
  "item_name" varchar,
  "effect_type" int,
  "effect_amount" int,
  "stackable" int
);

ALTER TABLE "instance"."user_char" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_char" ADD FOREIGN KEY ("character_id") REFERENCES "const"."characters" ("character_id");

ALTER TABLE "instance"."user_room" ADD FOREIGN KEY ("room_id") REFERENCES "socket"."rooms" ("room_id");

ALTER TABLE "instance"."user_room" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_item" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "instance"."user_item" ADD FOREIGN KEY ("item_id") REFERENCES "const"."items" ("item_id");

ALTER TABLE "const"."skills" ADD FOREIGN KEY ("character_id") REFERENCES "const"."characters" ("character_id");
