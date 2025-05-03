class Collections
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    @db.execute('PRAGMA foreign_keys = ON')
    
    return @db
  end

  def self.all
    return db.execute('SELECT * FROM collections')
  end

  def self.by_level_id(level_id)
    return db.exectue('SELECT collections.* FROM collections JOIN collection_levels ON collections.id = collection_levels.collection_id JOIN levels ON collection_levels.level_id = levels.id WHERE level_id = ?', [level_id.to_i])
  end

  def self.by_id_with_levels(id)
    return db.execute('SELECT levels.id AS level_id, levels.name AS level_name, levels.difficulty, levels.length_seconds, levels.length_text, collections.creator_id, collections.name AS collection_name, collections.id AS collection_id, collections.description AS collection_description FROM collections JOIN collection_levels ON collections.id = collection_levels.collection_id JOIN levels ON collection_levels.level_id = levels.id WHERE collection_levels.collection_id = ?', [id.to_i])
  end

  def self.by_id(id)
    return db.execute('SELECT * FROM collections WHERE id = ?', [id.to_i])
  end
end