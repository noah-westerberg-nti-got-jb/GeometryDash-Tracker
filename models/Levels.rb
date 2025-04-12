class Levels
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    @db.execute('PRAGMA foreign_keys = ON')
    
    return @db
  end

  def self.level_by_id(level_id)
    return db.execute("SELECT * FROM levels WHERE id = ?", level_id).first
  end

end