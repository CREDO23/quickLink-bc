-- Check if the user exists and create if not
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_user 
        WHERE  usename = 'johndoe') THEN
        CREATE USER johndoe WITH PASSWORD 'johndoepass';
        ALTER USER johndoe WITH SUPERUSER;
    END IF;
END
$$;

-- Create a new database if it doesn't exist
SELECT 'CREATE DATABASE quicklink'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quicklink')\gexec

-- Connect to the newly created database
\c quicklink

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create 'users' table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_schema = 'public' 
                   AND table_name = 'users') THEN
        CREATE TABLE users (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(50),
            password VARCHAR(255) NOT NULL,
            created_at TIMESTAMP,
            updated_at TIMESTAMP
        );
    END IF;
END
$$;

-- Create 'links' table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_schema = 'public' 
                   AND table_name = 'links') THEN
        CREATE TABLE links (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            long_form VARCHAR(255) NOT NULL UNIQUE,
            maker VARCHAR(255) NOT NULL UNIQUE,
            visit_times INTEGER DEFAULT 0,
            created_at TIMESTAMP,
            updated_at TIMESTAMP
        );
    END IF;
END
$$;

-- Create 'users_links' junction table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_schema = 'public' 
                   AND table_name = 'users_links') THEN
        CREATE TABLE users_links (
            user_id UUID NOT NULL,
            link_id UUID NOT NULL,
            PRIMARY KEY (user_id, link_id),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (link_id) REFERENCES links(id)
        );
    END IF;
END
$$;
