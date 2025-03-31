require_relative "Users"

class FollowList
  def self.db
    return @db if @db
    
    @db = SQLite3::Database.new("db/GDTracker.sqlite")
    @db.results_as_hash = true
    
    return @db
  end

  def self.get_following(user_id)
    return db.execute("SELECT recipient FROM follow_list WHERE follower = ?", user_id.to_i)
  end

  def self.get_followers(user_id)
    db.execute("SELECT follower FROM follow_list WHERE recipient = ?", user_id.to_i)
  end

  def self.follow(follower_id, recipient_id)
    return false unless Users.user_by_id(recipient_id)
    return false if is_following?(follower_id, recipient_id)
    
    db.execute("INSERT INTO follow_list (follower, recipient) VALUES (?, ?)", [follower_id.to_i, recipient_id.to_i])
    return true
  end

  def self.unfollow(follower_id, recipient_id)
    db.execute("DELETE FROM follow_list WHERE follower = ? AND recipient = ?", [follower_id.to_i, recipient_id.to_i])
    return true
  end

  def self.is_following?(follower_id, recipient_id)
    result = db.execute("SELECT * FROM follow_list WHERE follower = ? AND recipient = ?", [follower_id.to_i, recipient_id.to_i])
    p "is following result: #{result}"
    p "is following result not empty: #{result != []}"
    return result != []
  end

  def self.get_following_count(user_id)
    return db.execute("SELECT COUNT(*) FROM follow_list WHERE follower = ?", user_id.to_i).first["COUNT(*)"]
  end

  def self.get_follower_count(user_id)
    db.execute("SELECT COUNT(*) FROM follow_list WHERE recipient = ?", user_id.to_i).first["COUNT(*)"]
  end
end