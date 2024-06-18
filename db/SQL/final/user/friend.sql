-- Friend status function, given 2 user_id -> return friend_status
CREATE FUNCTION friend_status (user1_id INT, user2_id INT)
RETURNS INT AS $$
BEGIN
 IF EXISTS (SELECT 1 FROM friends WHERE user1_id = user_id AND user2_id = friend_id)
 THEN
   IF EXISTS (SELECT 1 FROM friends WHERE user1_id = friend_id AND user2_id = user_id)
   THEN
     RETURN 2;
   END IF;
 RETURN 1;
 ELSE
   RETURN 0;
 END IF;
END;
$$ LANGUAGE plpgsql

-- Search friends by name:
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp
FROM users 
WHERE friend_status(2, user_id) = 2 AND username LIKE '%'
ORDER BY (username, user_id)
LIMIT 10 OFFSET 10

-- Search friend by ID
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp
FROM users 
WHERE friend_status(1, user_id) = 2 AND user_id = 3

-- Show all friend request
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp 
FROM users WHERE friend_status(user_id, 1) = 1;

-- Send friend or request add friends 
INSERT INTO friends (user_id, friend_id) VALUES (1, 2);


-- Show player with the same level to add friend

SELECT user_id, email, username, point, level, exp
FROM users
WHERE 
ORDER BY (abs(level - 10)) ASC


-- Trigger to check max friend requests and max friends (200)
CREATE OR REPLACE FUNCTION check_friend_request()
RETURNS TRIGGER AS $$
DECLARE
    cnt_req INTEGER;
    cnt_friends INTEGER;
    del_item INTEGER;
BEGIN
    IF (NEW.user_id = NEW.friend_id) THEN
        RAISE EXCEPTION 'user_id and friend_id must be different';
    END IF;

    SELECT COUNT(users.user_id) FROM users WHERE friend_status(NEW.user_id, users.user_id) = 1
    INTO cnt_req;

    -- Delete oldest request if request length > 50
    IF (cnt_req+1 > 50) THEN
        SELECT friend_id FROM friends WHERE user_id = NEW.user_id AND friend_id IN (
            SELECT users.user_id FROM users WHERE friend_status(NEW.user_id, users.user_id) = 1
        ) ORDER BY (created_at) LIMIT 1 INTO del_item;
        DELETE FROM friends
        WHERE user_id = NEW.user_id AND friend_id = del_item;
    END IF;

    SELECT COUNT(users.user_id) FROM users WHERE friend_status(users.user_id, NEW.user_id) = 2
    INTO cnt_friends;

    IF (cnt_friends+1 > 200) THEN
        RAISE EXCEPTION 'NUMBER OF FRIENDS EXCEEDED';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_friend_request_trigger
BEFORE INSERT ON friends
FOR EACH ROW
EXECUTE FUNCTION check_friend_request();