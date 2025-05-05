-- Disconnect from current database (if connected)
\c postgres

-- Drop existing database if it exists
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_database WHERE datname = 'code3dbd') THEN
        -- Terminate all connections to the database
        PERFORM pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = 'code3dbd';

        -- Drop the database
        DROP DATABASE code3dbd;
        RAISE NOTICE 'Database code3dbd has been dropped';
    ELSE
        RAISE NOTICE 'Database code3dbd does not exist, proceeding with creation';
    END IF;
END
$$;

-- Create admin role if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'admin') THEN
        CREATE ROLE admin WITH LOGIN PASSWORD 'LoginPassword' CREATEDB CREATEROLE;
        RAISE NOTICE 'Role admin created';
    ELSE
        RAISE NOTICE 'Role admin already exists';
    END IF;
END
$$;

-- Create main database with Russian locale settings
CREATE DATABASE code3dbd
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'ru-RU'
    LC_CTYPE = 'ru-RU'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False
    TEMPLATE = template0;

-- Connect to the new database
\c code3dbd

-- Grant permissions
GRANT TEMPORARY, CONNECT ON DATABASE code3dbd TO PUBLIC;
GRANT ALL ON DATABASE code3dbd TO admin;
GRANT ALL ON DATABASE code3dbd TO postgres;

-- Create users table
CREATE TABLE IF NOT EXISTS public.users
(
    user_id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    username character varying(50) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    father_name character varying(50),
    gender character varying(6),
    email character varying(100) NOT NULL,
    password_hash character varying(200) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    superuser boolean DEFAULT false,
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_username_key UNIQUE (username)
);

ALTER TABLE public.users OWNER TO postgres;

-- Create posts table
CREATE TABLE IF NOT EXISTS public.posts (
    post_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    technology3d VARCHAR(8),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    code3d TEXT NOT NULL,
    type_of_work VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

ALTER TABLE public.posts OWNER TO postgres;

-- Function to update modified timestamp
CREATE OR REPLACE FUNCTION
update_posts_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;  -- Update the updated_at field
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ??????????? ??????? ? ???????
CREATE TRIGGER trigger_update_posts_modtime
BEFORE UPDATE ON public.posts
FOR EACH ROW
EXECUTE FUNCTION update_posts_modified();

-- Comments table with hierarchical structure
CREATE TABLE comments (
  comment_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  parent_comment_id INTEGER NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- Post likes junction table
CREATE TABLE post_likes (
  user_id INTEGER NOT NULL,
  post_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

-- Comment likes junction table
CREATE TABLE comment_likes (
  user_id INTEGER NOT NULL,
  comment_id INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, comment_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- Private messages table
CREATE TABLE private_messages (
  message_id SERIAL PRIMARY KEY,
  sender_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  receiver_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Optional field for tracking when message was read
  read_at TIMESTAMP NULL
);

-- Table for tracking deleted messages (soft delete implementation)
CREATE TABLE deleted_messages (
  user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  message_id INTEGER NOT NULL REFERENCES private_messages(message_id) ON DELETE CASCADE,
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, message_id)
);

RAISE NOTICE 'Database code3dbd and all tables created successfully';