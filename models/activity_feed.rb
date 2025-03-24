class ActivityFeed
  def db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    
    return @db
  end

  def new_attatchment(activity_id, type, link, item_id)
    
  end

  def new_activity(user_id, title, text, attatchment_id, created_at)
    
  end
end