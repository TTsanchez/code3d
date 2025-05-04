-- Database: code3dbd

-- DROP DATABASE IF EXISTS code3dbd;

CREATE DATABASE code3dbd
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

GRANT TEMPORARY, CONNECT ON DATABASE code3dbd TO PUBLIC;

GRANT ALL ON DATABASE code3dbd TO admin;

GRANT ALL ON DATABASE code3dbd TO postgres;


-- Table: public.users

-- DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS public.users
(
    user_id integer NOT NULL DEFAULT nextval('users_user_id_seq'::regclass),
    username character varying(50) COLLATE pg_catalog."default" NOT NULL,да 
    first_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    father_name character varying(50) COLLATE pg_catalog."default",
    gender character varying(6) COLLATE pg_catalog."default",
    email character varying(100) COLLATE pg_catalog."default" NOT NULL,
    password character varying(200) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp without time zone,
    superuser boolean DEFAULT false,
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_username_key UNIQUE (username)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;
    
    
-- Table: public.post

-- DROP TABLE IF EXISTS public.post;

CREATE TABLE IF NOT EXISTS public.post
(
    id integer NOT NULL DEFAULT nextval('post_id_seq'::regclass),
    created_at timestamp without time zone,
    technology3d character varying(8) COLLATE pg_catalog."default",
    title character varying(255) COLLATE pg_catalog."default",
    content text COLLATE pg_catalog."default",
    code3d text COLLATE pg_catalog."default",
    type_of_work character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT post_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.post
    OWNER to postgres;
    
    
-- Table: public.post_user

-- DROP TABLE IF EXISTS public.post_user;

CREATE TABLE IF NOT EXISTS public.post_user
(
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    CONSTRAINT post_user_pkey PRIMARY KEY (user_id, post_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.post_user
    OWNER to postgres;