class Completions
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    
    return @db
  end

  def self.completions_of_level(level_id)
    return db.execute("SELECT COUNT(user_id) FROM completions WHERE level_id = ? AND percentage = 100", level_id.to_i).first['COUNT(user_id)'].to_i
  end

  def self.completions_by_user(user_id)
    return db.execute("SELECT DISTINCT COUNT(user_id), level_id FROM completions WHERE user_id = ? AND percentage = 100", [user_id.to_i]).first['COUNT(user_id)'].to_i
  end

  def self.level_attempts(level_id)
    return db.execute("SELECT SUM(attempts) FROM completions WHERE level_id = ?", level_id.to_i).first['SUM(attempts)'].to_i
  end

  def self.level_attempts_by_user(level_id, user_id)
    return db.execute("SELECT SUM(attempts) FROM completions WHERE level_id = ? AND user_id = ?", [level_id.to_i, user_id.to_i]).first['SUM(attempts)'].to_i
  end

  def self.new_completion(user_id, level_id, percentage, attempts, perceived_difficulty, created_at)
    db.execute("INSERT INTO completions (user_id, level_id, percentage, attempts, perceived_difficulty, created_at) VALUES (?, ?, ?, ?, ?, ?)", [user_id, level_id, percentage, attempts, perceived_difficulty, created_at])
    return db.execute("SELECT id FROM completions WHERE user_id = ? AND level_id = ? AND created_at = ?", [user_id, level_id, created_at]).first['id']
  end
end