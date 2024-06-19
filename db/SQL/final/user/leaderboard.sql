-- Sort by point
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp 
FROM users 
ORDER BY (point) DESC 
LIMIT 10 OFFSET 0

-- Sort by level (LIMIT and OFFSET for page)
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp 
FROM users 
ORDER BY (level) DESC 
LIMIT 10 OFFSET 0

-- Search user by ID
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp
FROM users WHERE user_id = 3

-- Search user by name
SELECT 
    user_id, 
    email, 
    username, 
    point, 
    level, 
    exp
FROM users WHERE username LIKE "hello"
LIMIT 10 OFFSET 10


