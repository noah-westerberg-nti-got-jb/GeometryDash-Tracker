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
    return db.execute('SELECT collections.* FROM collections JOIN collection_levels ON collections.id = collection_levels.collection_id JOIN levels ON collection_levels.level_id = levels.id WHERE collection_levels.level_id = ?', [level_id.to_i])
  end

  def self.by_id_with_levels(id)
    return db.execute('SELECT levels.id AS level_id, levels.name AS level_name, levels.difficulty, levels.length_seconds, levels.length_text, collections.creator_id, collections.name AS collection_name, collections.id AS collection_id, collections.description AS collection_description FROM collections JOIN collection_levels ON collections.id = collection_levels.collection_id JOIN levels ON collection_levels.level_id = levels.id WHERE collection_levels.collection_id = ?', [id.to_i])
  end

  def self.by_id(id)
    return db.execute('SELECT * FROM collections WHERE id = ?', [id.to_i])
  end

  def self.by_user(user_id)
    return db.execute('SELECT * FROM collections WHERE creator_id = ?', [user_id.to_i])
  end

  def self.by_name_and_user_id(name, user_id)
    return db.execute('SELECT * FROM collections WHERE name = ? AND creator_id = ?', [name, user_id.to_i]).first
  end

  def self.new(user_id, name, description)
    db.execute('INSERT INTO collections (creator_id, name, description) VALUES (?, ?, ?)', [user_id.to_i, name, description])
    return self.by_name_and_user_id(name, user_id)['id']
  end

  def self.add_level(collection_id, level_id)
    db.execute('INSERT INTO collection_levels (collection_id, level_id) VALUES (?, ?)', [collection_id.to_i, level_id.to_i])
  end

  def self.delete(collection_id)
    db.execute('DELETE FROM collections WHERE id = ?', [collection_id.to_i])
  end
end