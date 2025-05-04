-- Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    father_name TEXT,
    gender TEXT CHECK(gender IN ('male', 'female', 'other')),
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    superuser BOOLEAN DEFAULT FALSE
);

-- Создание таблицы постов
CREATE TABLE IF NOT EXISTS posts (
    post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    technology3d TEXT CHECK(technology3d IN ('x3dom', 'verge3d')),
    title TEXT NOT NULL,
    content TEXT,
    code3d TEXT NOT NULL,
    type_of_work TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Триггер для автоматического обновления времени изменения (эмулируем PostgreSQL-функцию)
CREATE TRIGGER IF NOT EXISTS update_posts_modtime
AFTER UPDATE ON posts
BEGIN
    UPDATE posts SET updated_at = CURRENT_TIMESTAMP WHERE post_id = NEW.post_id;
END;

-- Таблица комментариев с иерархической структурой
CREATE TABLE IF NOT EXISTS comments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    parent_comment_id INTEGER,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- Таблица лайков постов
CREATE TABLE IF NOT EXISTS post_likes (
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

-- Таблица лайков комментариев
CREATE TABLE IF NOT EXISTS comment_likes (
    user_id INTEGER NOT NULL,
    comment_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, comment_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- Таблица личных сообщений
CREATE TABLE IF NOT EXISTS private_messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Таблица для отслеживания удаленных сообщений (мягкое удаление)
CREATE TABLE IF NOT EXISTS deleted_messages (
    user_id INTEGER NOT NULL,
    message_id INTEGER NOT NULL,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, message_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (message_id) REFERENCES private_messages(message_id) ON DELETE CASCADE
);

-- Создание администратора (эмулируем PostgreSQL DO-блок)
INSERT OR IGNORE INTO users (username, first_name, last_name, email, password_hash, superuser)
VALUES ('admin', 'Admin', 'Adminov', 'admin@example.com', 'хеш_пароля', TRUE);

-- Вывод сообщения о завершении (эмулируем RAISE NOTICE)
SELECT 'Database code3dbd and all tables created successfully' AS message;