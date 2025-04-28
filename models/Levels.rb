class Levels
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    @db.execute('PRAGMA foreign_keys = ON')
    
    return @db
  end

  def self.level_by_id(id)
    return db.execute("SELECT * FROM levels WHERE id = ?", [id]).first
  end

  def self.level_by_ingame_id(level_id)
    return db.execute("SELECT * FROM levels WHERE ingame_id = ?", [level_id]).first
  end

  def self.level_by_name(name)
    return db.execute("SELECT * FROM levels WHERE name = ?", [name]).first
  end

  def self.new(level_id, name, difficulty, length_text)
    db.execute("INSERT INTO levels (ingame_id, name, difficulty, length_text) VALUES (?, ?, ?, ?)", [level_id.to_i, name, difficulty, length_text])
    return db.execute("SELECT id from levels WHERE ingame_id = ?", [level_id]).first['id']
  end

  def self.all
    return db.execute("SELECT * FROM levels")
  end

end