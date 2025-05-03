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

  def self.level_by_name(name)
    return db.execute("SELECT * FROM levels WHERE name = ?", [name]).first
  end

  def self.new(level_id, name, difficulty, length_text)
    db.execute("INSERT INTO levels (id, name, difficulty, length_text) VALUES (?, ?, ?, ?)", [level_id.to_i, name, difficulty, length_text])
  end

  def self.all
    return db.execute("SELECT * FROM levels")
  end

  def self.by_collection_id(collection_id)
    return db.execute('SELECT levels.* FROM levels JOIN collection_levels ON levels.id = collection_levels.level_id WHERE collection_levels.collection_id = ?', [collection_id.to_i])
  end
end