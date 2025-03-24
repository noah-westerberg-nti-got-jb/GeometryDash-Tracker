class Completions
  def initialize(db)
    @db = db
  end

  def level_completions(level_id)
    return @db.execute("SELECT COUNT(user_id) FROM completions WHERE level_id = ? AND percentage = 100", level_id.to_i).first['COUNT(user_id)'].to_i
  end

  def level_attempts(level_id)
    return @db.execute("SELECT SUM(attempts) FROM completions WHERE level_id = ?", level_id.to_i).first['SUM(attempts)'].to_i
  end

  def level_attempts_by_user(level_id, user_id)
    return @db.execute("SELECT SUM(attempts) FROM completions WHERE level_id = ? AND user_id = ?", [level_id.to_i, user_id.to_i]).first['SUM(attempts)'].to_i
  end

  def new_completion(user_id, level_id, percentage, attempts, perceived_difficulty, created_at)
    @db.execute("INSERT INTO completions (user_id, level_id, percentage, attempts, perceived_difficulty, created_at) VALUES (?, ?, ?, ?, ?, ?)", [user_id, level_id, percentage, attempts, perceived_difficulty, created_at])
  end
end