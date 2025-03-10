require 'sqlite3'
require 'bcrypt'

class Seeder

  def self.seed!
	drop_tables
    create_tables
  end

  def self.drop_tables
	db.execute('DROP TABLE IF EXISTS users')
	db.execute('DROP TABLE IF EXISTS levels')
	db.execute('DROP TABLE IF EXISTS activity_feed')
	db.execute('DROP TABLE IF EXISTS follow_list')
	db.execute('DROP TABLE IF EXISTS completions')
  end

  def self.create_tables
    db.execute('CREATE TABLE users (
      			id INTEGER PRIMARY KEY AUTOINCREMENT,
      			username TEXT NOT NULL UNIQUE,
      			password TEXT NOT NULL,
      			score INTEGER NOT NULL DEFAULT 0,
						created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)'
      			)

    db.execute('CREATE TABLE levels (
      			ingame_id INTEGER PRIMARY KEY,
				name TEXT NOT NULL)'
				)
				# TODO: Add more relevant information

	db.execute('CREATE TABLE activities (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				user_id INTEGER NOT NULL,
				title TEXT NOT NULL,
				contents TEXT,
				attatchment TEXT,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY(user_id) REFERENCES users(id))'
				)

	db.execute('CREATE TABLE follow_list (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				follower INTEGER NOT NULL,
				recipient INTEGER NOT NULL,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY(follower) REFERENCES users(id),
				FOREIGN KEY(recipient) REFERENCES users(id))'
				)

	db.execute('CREATE TABLE completions (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				user_id INTEGER NOT NULL,
				level_id INTEGER NOT NULL,
				total_attempts INTEGER NOT NULL,
				practice_attempts INTEGER,
				perceived_difficulty INTEGER,
				created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY(user_id) REFERENCES users(id),
				FOREIGN KEY (level_id) REFERENCES levels(ingame_id))'
				)

	# Create admin user
	admin_password = BCrypt::Password.create("admin")
	db.execute('INSERT INTO users (username, password, score) VALUES ("admin", ?, -1)', [admin_password])
  end

  def self.db 
    return @db if @db
    @db = SQLite3::Database.new 'db/GDTracker.sqlite'
    @db.results_as_hash = true
    return @db
  end
end
