CREATE TABLE IF NOT EXISTS "users" (
  "user_id" int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  "email" varchar,
  "username" varchar,
  "password" varchar
);

INSERT INTO users(email, username, pwd) VALUES ('13', 'sdhawd', 'dsiauda');