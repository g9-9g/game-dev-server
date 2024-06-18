CREATE ROLE change_assets;

GRANT ALL PRIVILEGES ON TABLE characters TO change_assets;
GRANT ALL PRIVILEGES ON TABLE weapons TO change_assets;
GRANT ALL PRIVILEGES ON TABLE effect TO change_assets;
GRANT ALL PRIVILEGES ON TABLE skills TO change_assets;

CREATE ROLE change_user;

GRANT ALL PRIVILEGES ON TABLE users TO change_user;

-- Admin
CREATE USER admin_ex WITH PASSWORD '123';

GRANT change_assets,change_user,client_friend,fetch_weapon,fetch_char,client_auth TO admin_ex;
