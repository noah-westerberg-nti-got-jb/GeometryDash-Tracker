class Users
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    @db.execute('PRAGMA foreign_keys = ON')
    
    return @db
  end

  def self.all_users
    return db.execute("SELECT * FROM users")
  end

  def self.user_by_id(user_id)
    return db.execute("SELECT * FROM users WHERE id = ?", [user_id.to_i]).first
  end

  def self.user_by_name(username)
    return db.execute("SELECT * FROM users WHERE username = ?", [username]).first
  end

  def self.change_username(user_id, new_name)
    return false if db.execute("SELECT username FROM users WHERE username = ?", [new_name]) != []
  
    db.execute("UPDATE users SET username = ? WHERE id = ?", [new_name, user_id.to_i])
    return true
  end

  def self.delete_user(user_id)
    db.execute("DELETE FROM users WHERE id = ?", [user_id.to_i]) if user_id != 1
  end

  def self.create_user(username, password)
    return false if db.execute("SELECT username FROM users WHERE username = ?", [username]) != []
  
    hashed_password = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, hashed_password])
    return true
  end
end