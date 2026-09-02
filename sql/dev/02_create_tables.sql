-- users
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR NOT NULL,
    user_email VARCHAR NOT NULL,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- roles
CREATE TABLE IF NOT EXISTS roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR NOT NULL,
    role_description VARCHAR NOT NULL,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- user_roles
CREATE TABLE IF NOT EXISTS user_roles (
    user_role_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    role_id INTEGER NOT NULL REFERENCES roles(role_id),
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- industry
CREATE TABLE IF NOT EXISTS industry (
    industry_id VARCHAR(100) PRIMARY KEY,
    industry VARCHAR,
    description TEXT,
    username VARCHAR,
    date_time TIMESTAMP DEFAULT current_timestamp,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- persona
CREATE TABLE IF NOT EXISTS persona (
    persona_id VARCHAR(100) PRIMARY KEY,
    industry VARCHAR,
    industry_id VARCHAR(100),
    persona VARCHAR,
    filepath VARCHAR,
    file_upload_type VARCHAR,
    description VARCHAR,
    model VARCHAR,
    type_model VARCHAR,
    username VARCHAR,
    date_time TIMESTAMP DEFAULT current_timestamp,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- embed_output
CREATE TABLE IF NOT EXISTS embed_output (
    embed_id VARCHAR(100) PRIMARY KEY,
    filepath VARCHAR,
    model_name VARCHAR,
    type_model VARCHAR,
    results VARCHAR,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- user_chat_data
CREATE TABLE IF NOT EXISTS user_chat_data (
    id SERIAL PRIMARY KEY,
    chat_id VARCHAR(100) NOT NULL,
    instance_id VARCHAR(100),
    model_name VARCHAR(255),
    type_model VARCHAR(100),
    question TEXT,
    answer TEXT,
    feedback VARCHAR(50),
    feedback_comment TEXT,
    date_time TIMESTAMP DEFAULT current_timestamp,
    user_email VARCHAR,
    input_token INTEGER,
    output_token INTEGER,
    total_count DOUBLE PRECISION,
    group_name VARCHAR,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);

-- groups_members
CREATE TABLE IF NOT EXISTS groups_members (
    id SERIAL PRIMARY KEY,
    group_name VARCHAR,
    member VARCHAR,
    description VARCHAR,
    create_user VARCHAR DEFAULT current_user,
    create_time TIMESTAMP DEFAULT current_timestamp
);
