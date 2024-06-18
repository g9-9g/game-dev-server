CREATE ROLE client_auth;

GRANT SELECT, INSERT, UPDATE(points, username, level, exp, password, email) ON TABLE users TO client_auth;

CREATE ROLE fetch_char;

GRANT SELECT ON TABLE characters TO fetch_char;
GRANT SELECT, INSERT, UPDATE ON TABLE user_char TO fetch_char;
GRANT SELECT ON TABLE skills TO fetch_char;
GRANT SELECT ON TABLE effect TO fetch_char;

CREATE ROLE fetch_weapon;

GRANT SELECT ON TABLE weapons TO fetch_weapon;
GRANT SELECT, INSERT ON TABLE user_weapon TO fetch_weapon;

CREATE ROLE client_friend;
GRANT SELECT, INSERT ON TABLE friends TO client_friend;

-- Example role
CREATE USER client_example1 WITH PASSWORD '123';

GRANT client_friend,fetch_weapon,fetch_char,client_auth TO client_example1;