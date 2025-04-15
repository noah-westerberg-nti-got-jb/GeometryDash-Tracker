class ActivityFeed
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    @db.execute('PRAGMA foreign_keys = ON')
    
    return @db
  end

  def self.new_attatchment(activity_id, type, link, item_id)
    
  end

  def self.new_activity(user_id, title, text, attatchment_id, created_at)
    
  end

  def self.activities_from_users(user_ids)
    unless user_ids
      return
    end
    
    return db.execute('SELECT * FROM activities WHERE user_id IN (?)', [user_ids])
  end

  def self.delete_activity(activity_id)
    db.execute('DELETE FROM activities WHERE id = ?', activity_id)
  end
end