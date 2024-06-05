--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: are_friends(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.are_friends(player1 integer, player2 integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM friends 
        WHERE (player_id = player1 AND friend_id = player2) 
           OR (player_id = player2 AND friend_id = player1)
    );
END;
$$;


ALTER FUNCTION public.are_friends(player1 integer, player2 integer) OWNER TO postgres;

--
-- Name: assign_skills(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.assign_skills() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    skill_ids INTEGER[];
BEGIN
    -- Get 4 distinct skill_ids from the skills table
    SELECT ARRAY_AGG(skill_id) INTO skill_ids
    FROM (
        SELECT * FROM skills WHERE character_id = NEW.character_id ORDER BY (level_req) LIMIT 4
    ) sub;

    IF array_length(skill_ids, 1) < 4 THEN
        RAISE EXCEPTION 'Not enough distinct skills available';
    END IF;

    -- Assign these skills to the new row
    NEW.skill1_id := skill_ids[1];
    NEW.skill2_id := skill_ids[2];
    NEW.skill3_id := skill_ids[3];
    NEW.skill4_id := skill_ids[4];

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.assign_skills() OWNER TO postgres;

--
-- Name: check_valid_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_valid_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (OLD.weapon_id IS DISTINCT FROM NEW.weapon_id) THEN
        IF ( NOT EXISTS (SELECT wp_id FROM user_weapon WHERE wp_id = NEW.weapon_id AND user_id = OLD.user_id)) THEN
            RAISE EXCEPTION 'No exist weapon';
        END IF;
    END IF;

    IF (OLD.skill1_id IS DISTINCT FROM NEW.skill1_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill1_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 1';
        END IF;
    END IF;

    IF (OLD.skill2_id IS DISTINCT FROM NEW.skill2_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill2_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 2';
        END IF;
    END IF;

    IF (OLD.skill3_id IS DISTINCT FROM NEW.skill3_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill3_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 3';
        END IF;
    END IF;

    IF (OLD.skill4_id IS DISTINCT FROM NEW.skill4_id) THEN
        IF ( NOT EXISTS (SELECT character_id FROM user_char JOIN skills ON NEW.skill4_id = skills.skill_id WHERE skills.character_id = NEW.character_id)) THEN
            RAISE EXCEPTION 'No exist skill 4';
        END IF;
    END IF;

    IF ( NEW.skill1_id = NEW.skill2_id OR NEW.skill2_id = NEW.skill3_id OR NEW.skill3_id = NEW.skill4_id OR NEW.skill1_id = NEW.skill3_id OR NEW.skill2_id = NEW.skill4_id OR NEW.skill1_id = NEW.skill4_id ) THEN
        RAISE EXCEPTION '4 skill must be unique';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_valid_update() OWNER TO postgres;

--
-- Name: random_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.random_timestamp() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.random_timestamp() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: characters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.characters (
    character_id integer NOT NULL,
    character_name character varying,
    character_class character varying,
    base_hp integer DEFAULT 0,
    base_def integer DEFAULT 0,
    base_atk integer DEFAULT 0,
    multiplier integer DEFAULT 0
);


ALTER TABLE public.characters OWNER TO postgres;

--
-- Name: characters_character_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.characters_character_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.characters_character_id_seq OWNER TO postgres;

--
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.characters_character_id_seq OWNED BY public.characters.character_id;


--
-- Name: effect; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.effect (
    effect_id integer NOT NULL,
    object_id integer NOT NULL,
    stunt_amount integer DEFAULT 0,
    stunt_duration integer DEFAULT 0,
    slow_amount integer DEFAULT 0,
    slow_duration integer DEFAULT 0,
    effect_req integer DEFAULT 0
);


ALTER TABLE public.effect OWNER TO postgres;

--
-- Name: effect_effect_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.effect_effect_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.effect_effect_id_seq OWNER TO postgres;

--
-- Name: effect_effect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.effect_effect_id_seq OWNED BY public.effect.effect_id;


--
-- Name: effect_object_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.effect_object_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.effect_object_id_seq OWNER TO postgres;

--
-- Name: effect_object_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.effect_object_id_seq OWNED BY public.effect.object_id;


--
-- Name: friends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friends (
    user_id integer NOT NULL,
    friend_id integer NOT NULL,
    create_at timestamp without time zone NOT NULL
);


ALTER TABLE public.friends OWNER TO postgres;

--
-- Name: friends_friend_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.friends_friend_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.friends_friend_id_seq OWNER TO postgres;

--
-- Name: friends_friend_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.friends_friend_id_seq OWNED BY public.friends.friend_id;


--
-- Name: friends_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.friends_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.friends_user_id_seq OWNER TO postgres;

--
-- Name: friends_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.friends_user_id_seq OWNED BY public.friends.user_id;


--
-- Name: object_key; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.object_key
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.object_key OWNER TO postgres;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    skill_id integer DEFAULT nextval('public.object_key'::regclass) NOT NULL,
    character_id integer NOT NULL,
    skill_name character varying,
    level_req integer DEFAULT 0
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: skills_character_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.skills_character_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skills_character_id_seq OWNER TO postgres;

--
-- Name: skills_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skills_character_id_seq OWNED BY public.skills.character_id;


--
-- Name: skills_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.skills_skill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skills_skill_id_seq OWNER TO postgres;

--
-- Name: skills_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skills_skill_id_seq OWNED BY public.skills.skill_id;


--
-- Name: user_char; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_char (
    id integer NOT NULL,
    user_id integer NOT NULL,
    character_id integer,
    characters_level integer DEFAULT 0,
    weapon_id integer NOT NULL,
    skill1_id integer NOT NULL,
    skill2_id integer NOT NULL,
    skill3_id integer NOT NULL,
    skill4_id integer NOT NULL
);


ALTER TABLE public.user_char OWNER TO postgres;

--
-- Name: test_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.test_view AS
 SELECT characters.character_id,
    COALESCE(ownedchar.characters_level, '-1'::integer) AS "coalesce",
    characters.character_class,
    characters.base_hp,
    characters.base_def,
    characters.base_atk,
    characters.multiplier,
    ownedchar.weapon_id,
    ownedchar.skill1_id,
    ownedchar.skill2_id,
    ownedchar.skill3_id,
    ownedchar.skill4_id
   FROM (public.characters
     LEFT JOIN ( SELECT user_char.character_id,
            user_char.characters_level,
            user_char.weapon_id,
            user_char.skill1_id,
            user_char.skill2_id,
            user_char.skill3_id,
            user_char.skill4_id
           FROM public.user_char
          WHERE (user_char.user_id = 2)) ownedchar ON ((ownedchar.character_id = characters.character_id)));


ALTER VIEW public.test_view OWNER TO postgres;

--
-- Name: user_char_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_id_seq OWNER TO postgres;

--
-- Name: user_char_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_id_seq OWNED BY public.user_char.id;


--
-- Name: user_char_skill1_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_skill1_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_skill1_id_seq OWNER TO postgres;

--
-- Name: user_char_skill1_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_skill1_id_seq OWNED BY public.user_char.skill1_id;


--
-- Name: user_char_skill2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_skill2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_skill2_id_seq OWNER TO postgres;

--
-- Name: user_char_skill2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_skill2_id_seq OWNED BY public.user_char.skill2_id;


--
-- Name: user_char_skill3_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_skill3_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_skill3_id_seq OWNER TO postgres;

--
-- Name: user_char_skill3_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_skill3_id_seq OWNED BY public.user_char.skill3_id;


--
-- Name: user_char_skill4_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_skill4_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_skill4_id_seq OWNER TO postgres;

--
-- Name: user_char_skill4_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_skill4_id_seq OWNED BY public.user_char.skill4_id;


--
-- Name: user_char_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_user_id_seq OWNER TO postgres;

--
-- Name: user_char_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_user_id_seq OWNED BY public.user_char.user_id;


--
-- Name: user_char_weapon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_char_weapon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_char_weapon_id_seq OWNER TO postgres;

--
-- Name: user_char_weapon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_char_weapon_id_seq OWNED BY public.user_char.weapon_id;


--
-- Name: user_weapon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_weapon (
    id integer NOT NULL,
    user_id integer NOT NULL,
    wp_id integer NOT NULL,
    wp_level integer DEFAULT 0
);


ALTER TABLE public.user_weapon OWNER TO postgres;

--
-- Name: user_weapon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_weapon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_weapon_id_seq OWNER TO postgres;

--
-- Name: user_weapon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_weapon_id_seq OWNED BY public.user_weapon.id;


--
-- Name: user_weapon_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_weapon_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_weapon_user_id_seq OWNER TO postgres;

--
-- Name: user_weapon_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_weapon_user_id_seq OWNED BY public.user_weapon.user_id;


--
-- Name: user_weapon_wp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_weapon_wp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_weapon_wp_id_seq OWNER TO postgres;

--
-- Name: user_weapon_wp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_weapon_wp_id_seq OWNED BY public.user_weapon.wp_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    email character varying,
    username character varying,
    password character varying,
    point integer DEFAULT 0,
    level integer DEFAULT 0,
    exp integer DEFAULT 0
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: weapons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weapons (
    wp_id integer DEFAULT nextval('public.object_key'::regclass) NOT NULL,
    wp_name character varying,
    wp_req integer DEFAULT 0,
    base_hp integer DEFAULT 0,
    base_def integer DEFAULT 0,
    base_atk integer DEFAULT 0,
    multiplier integer DEFAULT 0,
    wp_class character varying,
    rarity integer
);


ALTER TABLE public.weapons OWNER TO postgres;

--
-- Name: weapons_wp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weapons_wp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weapons_wp_id_seq OWNER TO postgres;

--
-- Name: weapons_wp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weapons_wp_id_seq OWNED BY public.weapons.wp_id;


--
-- Name: characters character_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters ALTER COLUMN character_id SET DEFAULT nextval('public.characters_character_id_seq'::regclass);


--
-- Name: effect effect_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.effect ALTER COLUMN effect_id SET DEFAULT nextval('public.effect_effect_id_seq'::regclass);


--
-- Name: effect object_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.effect ALTER COLUMN object_id SET DEFAULT nextval('public.effect_object_id_seq'::regclass);


--
-- Name: friends user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends ALTER COLUMN user_id SET DEFAULT nextval('public.friends_user_id_seq'::regclass);


--
-- Name: friends friend_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends ALTER COLUMN friend_id SET DEFAULT nextval('public.friends_friend_id_seq'::regclass);


--
-- Name: skills character_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills ALTER COLUMN character_id SET DEFAULT nextval('public.skills_character_id_seq'::regclass);


--
-- Name: user_char id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN id SET DEFAULT nextval('public.user_char_id_seq'::regclass);


--
-- Name: user_char user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN user_id SET DEFAULT nextval('public.user_char_user_id_seq'::regclass);


--
-- Name: user_char weapon_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN weapon_id SET DEFAULT nextval('public.user_char_weapon_id_seq'::regclass);


--
-- Name: user_char skill1_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN skill1_id SET DEFAULT nextval('public.user_char_skill1_id_seq'::regclass);


--
-- Name: user_char skill2_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN skill2_id SET DEFAULT nextval('public.user_char_skill2_id_seq'::regclass);


--
-- Name: user_char skill3_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN skill3_id SET DEFAULT nextval('public.user_char_skill3_id_seq'::regclass);


--
-- Name: user_char skill4_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char ALTER COLUMN skill4_id SET DEFAULT nextval('public.user_char_skill4_id_seq'::regclass);


--
-- Name: user_weapon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_weapon ALTER COLUMN id SET DEFAULT nextval('public.user_weapon_id_seq'::regclass);


--
-- Name: user_weapon user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_weapon ALTER COLUMN user_id SET DEFAULT nextval('public.user_weapon_user_id_seq'::regclass);


--
-- Name: user_weapon wp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_weapon ALTER COLUMN wp_id SET DEFAULT nextval('public.user_weapon_wp_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.characters (character_id, character_name, character_class, base_hp, base_def, base_atk, multiplier) FROM stdin;
1	Warrior	Tank	1000	300	100	2
2	Mage	Caster	600	100	300	3
3	Rogue	DPS	800	200	200	3
4	Staff of HOMA	Staff	100	20	200	30
5	Hutao	sword	100	20	200	30
6	ong dang	tanker	1000	10	1000	1
9	ong dang2	tanker	1000	10	1000	1
11	hello	dmm	100	100	100	100
15	hello2	dmm	100	100	100	100
17	ong dang3	tanker	1000	10	1000	1
19	ong dang5	tanker	1000	10	1000	1
20	ong dang6	tanker	1000	10	1000	1
\.


--
-- Data for Name: effect; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.effect (effect_id, object_id, stunt_amount, stunt_duration, slow_amount, slow_duration, effect_req) FROM stdin;
13	1	10	5	0	0	1
14	2	0	0	15	10	2
15	3	20	7	5	5	3
16	4	25	10	10	10	4
17	10	0	1	2	3	4
18	10	10	11	12	13	14
19	10	0	1	2	3	4
20	10	10	11	12	13	14
21	10	0	1	2	3	4
22	10	10	11	12	13	14
\.


--
-- Data for Name: friends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friends (user_id, friend_id, create_at) FROM stdin;
1	2	2023-07-01 18:10:57.202176
2	1	2023-06-09 17:53:48.202176
1	3	2023-11-11 10:05:37.202176
3	1	2023-07-07 23:38:17.202176
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (skill_id, character_id, skill_name, level_req) FROM stdin;
1	1	Shield Bash	1
2	1	Taunt	5
3	2	Fireball	1
4	2	Ice Blast	5
5	3	Backstab	1
6	3	Shadow Step	5
10	1	Power Strike	10
11	1	War Cry	15
12	1	Defensive Stance	20
13	1	Berserk	25
20	4	Fireeee	0
22	4	Fireeee	0
23	4	Fireeee2	0
24	4	Fireeee2	0
25	4	Fireeee2	0
26	4	Fireeee2	0
27	4	Fireeee2	0
28	4	Fireeee2	0
29	9	toiyeugenshin	0
30	9	toiyeuhonkai	0
31	9	:v	0
32	9	lmao	0
33	11	dmm	0
34	15	dmm	0
35	15	dmm	2
36	17	toiyeugenshin	0
37	17	toiyeuhonkai	0
38	17	:v	0
39	17	lmao	0
40	19	toiyeugenshin	0
41	19	toiyeuhonkai	0
42	19	:v	0
43	19	lmao	0
44	20	toiyeugenshin	0
45	20	toiyeuhonkai	0
46	20	:v	0
47	20	lmao	0
\.


--
-- Data for Name: user_char; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_char (id, user_id, character_id, characters_level, weapon_id, skill1_id, skill2_id, skill3_id, skill4_id) FROM stdin;
5	1	1	10	1	1	2	1	1
6	2	2	8	2	3	4	1	1
7	3	3	5	3	5	6	1	1
8	1	2	0	1	1	1	1	1
9	1	3	0	2	2	2	2	2
11	2	1	0	1	1	2	10	11
16	2	4	0	1	20	22	23	24
\.


--
-- Data for Name: user_weapon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_weapon (id, user_id, wp_id, wp_level) FROM stdin;
1	1	1	2
2	2	2	1
3	3	3	3
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, email, username, password, point, level, exp) FROM stdin;
1	alice@example.com	alice	hashed_password1	100	5	1500
2	bob@example.com	bob	hashed_password2	200	10	3000
3	charlie@example.com	charlie	hashed_password3	50	3	500
4	meikou5@gmail.com	ong_dang5	$2b$10$A9dH.//ymzMvaIkulGHl2uuf2aqexVb07inopz6.rQn/1z7IY8T8.	0	0	0
\.


--
-- Data for Name: weapons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weapons (wp_id, wp_name, wp_req, base_hp, base_def, base_atk, multiplier, wp_class, rarity) FROM stdin;
1	Sword of Valor	1	50	10	100	1	Sword	\N
2	Staff of Wisdom	1	20	5	150	2	Sword	\N
3	Dagger of Speed	1	30	8	120	1	Sword	\N
21	staff of homa	0	0	0	0	0	Sword	\N
\.


--
-- Name: characters_character_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.characters_character_id_seq', 20, true);


--
-- Name: effect_effect_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.effect_effect_id_seq', 22, true);


--
-- Name: effect_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.effect_object_id_seq', 1, false);


--
-- Name: friends_friend_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friends_friend_id_seq', 1, false);


--
-- Name: friends_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friends_user_id_seq', 1, false);


--
-- Name: object_key; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.object_key', 47, true);


--
-- Name: skills_character_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skills_character_id_seq', 1, false);


--
-- Name: skills_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skills_skill_id_seq', 6, true);


--
-- Name: user_char_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_id_seq', 16, true);


--
-- Name: user_char_skill1_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_skill1_id_seq', 2, true);


--
-- Name: user_char_skill2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_skill2_id_seq', 2, true);


--
-- Name: user_char_skill3_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_skill3_id_seq', 2, true);


--
-- Name: user_char_skill4_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_skill4_id_seq', 2, true);


--
-- Name: user_char_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_user_id_seq', 1, false);


--
-- Name: user_char_weapon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_char_weapon_id_seq', 2, true);


--
-- Name: user_weapon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_weapon_id_seq', 3, true);


--
-- Name: user_weapon_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_weapon_user_id_seq', 1, false);


--
-- Name: user_weapon_wp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_weapon_wp_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 4, true);


--
-- Name: weapons_wp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.weapons_wp_id_seq', 3, true);


--
-- Name: characters characters_character_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_character_name_key UNIQUE (character_name);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- Name: effect effect_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.effect
    ADD CONSTRAINT effect_pkey PRIMARY KEY (effect_id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (skill_id);


--
-- Name: user_char unique_user_char; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT unique_user_char UNIQUE (user_id, character_id);


--
-- Name: user_char user_char_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_pkey PRIMARY KEY (id);


--
-- Name: user_weapon user_weapon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_weapon
    ADD CONSTRAINT user_weapon_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: weapons weapons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapons
    ADD CONSTRAINT weapons_pkey PRIMARY KEY (wp_id);


--
-- Name: weapons weapons_wp_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weapons
    ADD CONSTRAINT weapons_wp_name_key UNIQUE (wp_name);


--
-- Name: user_char before_insert_user_char; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_user_char BEFORE INSERT ON public.user_char FOR EACH ROW EXECUTE FUNCTION public.assign_skills();


--
-- Name: user_char check_valid_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_valid_update_trigger BEFORE UPDATE ON public.user_char FOR EACH ROW EXECUTE FUNCTION public.check_valid_update();


--
-- Name: effect effect_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.effect
    ADD CONSTRAINT effect_object_id_fkey FOREIGN KEY (object_id) REFERENCES public.skills(skill_id);


--
-- Name: friends friends_friend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES public.users(user_id);


--
-- Name: friends friends_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friends
    ADD CONSTRAINT friends_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: skills skills_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(character_id);


--
-- Name: user_char user_char_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(character_id);


--
-- Name: user_char user_char_skill1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_skill1_id_fkey FOREIGN KEY (skill1_id) REFERENCES public.skills(skill_id);


--
-- Name: user_char user_char_skill2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_skill2_id_fkey FOREIGN KEY (skill2_id) REFERENCES public.skills(skill_id);


--
-- Name: user_char user_char_skill3_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_skill3_id_fkey FOREIGN KEY (skill3_id) REFERENCES public.skills(skill_id);


--
-- Name: user_char user_char_skill4_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_skill4_id_fkey FOREIGN KEY (skill4_id) REFERENCES public.skills(skill_id);


--
-- Name: user_char user_char_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: user_char user_char_weapon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_char
    ADD CONSTRAINT user_char_weapon_id_fkey FOREIGN KEY (weapon_id) REFERENCES public.user_weapon(id);


--
-- Name: user_weapon user_weapon_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_weapon
    ADD CONSTRAINT user_weapon_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: user_weapon user_weapon_wp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_weapon
    ADD CONSTRAINT user_weapon_wp_id_fkey FOREIGN KEY (wp_id) REFERENCES public.weapons(wp_id);


--
-- PostgreSQL database dump complete
--

