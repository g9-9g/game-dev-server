CREATE TABLE "users" (
  "user_id" SERIAL PRIMARY KEY,
  "email" varchar UNIQUE,
  "username" varchar UNIQUE,
  "password" varchar,
  "point" int DEFAULT 0,
  "level" int DEFAULT 0,
  "exp" int DEFAULT 0
);