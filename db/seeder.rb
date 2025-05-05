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
		db.execute('DROP TABLE IF EXISTS activity_attachments')
		db.execute('DROP TABLE IF EXISTS activities')
		db.execute('DROP TABLE IF EXISTS follow_list')
		db.execute('DROP TABLE IF EXISTS completions')
		db.execute('DROP TABLE IF EXISTS collections')
		db.execute('DROP TABLE IF EXISTS collection_levels')
		
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
      			id INTEGER PRIMARY KEY,
						name TEXT,
						difficulty TEXT NOT NULL,
						length_text TEXT NOT NULL,
						length_seconds INTEGER)'
						)

		db.execute('CREATE TABLE activity_attachments (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					activity_id INTEGER NOT NULL,
					type TEXT NOT NULL,
					value TEXT NOT NULL,
					FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE)'
					)

		db.execute('CREATE TABLE activities (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					user_id INTEGER NOT NULL,
					title TEXT NOT NULL DEFAULT "New Activity",
					created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
					FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL)'
					)

		db.execute('CREATE TABLE follow_list (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					follower INTEGER NOT NULL,
					recipient INTEGER NOT NULL,
					created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
					FOREIGN KEY (follower) REFERENCES users(id) ON DELETE CASCADE,
					FOREIGN KEY (recipient) REFERENCES users(id) ON DELETE CASCADE)'
					)

		db.execute('CREATE TABLE completions (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					user_id INTEGER NOT NULL,
					level_id INTEGER NOT NULL,
					percentage REAL NOT NULL,
					attempts INTEGER NOT NULL,
					perceived_difficulty INTEGER DEFAULT 0,
					created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
					FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
					FOREIGN KEY (level_id) REFERENCES levels(id) ON DELETE CASCADE)'
					)

		db.execute('CREATE TABLE collections (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					creator_id INTEGER NOT NULL,
					name TEXT NOT NULL,
					description TEXT,
					FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE)'
		)

		db.execute('CREATE TABLE collection_levels (
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					collection_id INTEGER NOT NULL,
					level_id INTEGER NOT NULL,
					FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE,
					FOREIGN KEY (level_id) REFERENCES levels(id) ON DELETE CASCADE)'
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

  def self.test_data!
	self.seed!

	db.execute('INSERT INTO users (username, password, score) VALUES ("test_user_1", ?, 3)', [BCrypt::Password.create("test_password1")])
	db.execute('INSERT INTO users (username, password, score) VALUES ("test_user_2", ?, 10)', [BCrypt::Password.create("test_password2")])
	db.execute('INSERT INTO users (username, password, score) VALUES ("test_user_3", ?, 2)', [BCrypt::Password.create("test_password3")])

	db.execute('INSERT INTO levels (id, name, difficulty, length_text) VALUES (1, "Level 1", "easy", "short")')
	db.execute('INSERT INTO levels (id, name, difficulty, length_text) VALUES (2, "Level 2", "medium", "medium")')
	db.execute('INSERT INTO levels (id, name, difficulty, length_text) VALUES (3, "Level 3", "hard", "long")')

	db.execute('INSERT INTO collections (creator_id, name, description) VALUES (1, "Collection 1", "Description 1")')
	db.execute('INSERT INTO collection_levels (collection_id, level_id) VALUES (1, 1)')
	db.execute('INSERT INTO collection_levels (collection_id, level_id) VALUES (1, 3)')

	db.execute('INSERT INTO collections (creator_id, name, description) VALUES (2, "Awsome levels", "The best levels")')
	db.execute('INSERT INTO collection_levels (collection_id, level_id) VALUES (2, 1)')
	db.execute('INSERT INTO collection_levels (collection_id, level_id) VALUES (2, 2)')
	db.execute('INSERT INTO collection_levels (collection_id, level_id) VALUES (2, 3)')

	db.execute('INSERT INTO follow_list (follower, recipient) VALUES (2, 3)')
	db.execute('INSERT INTO follow_list (follower, recipient) VALUES (2, 3)')
	db.execute('INSERT INTO follow_list (follower, recipient) VALUES (3, 4)')
	db.execute('INSERT INTO follow_list (follower, recipient) VALUES (4, 2)')
	db.execute('INSERT INTO follow_list (follower, recipient) VALUES (2, 4)')
  end
end
