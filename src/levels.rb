App.namespace "/levels" do 
    get "/new", :loggedIn => "/" do
      erb :"levels/new"
    end
  
  get "/:level_id" do |level_id|
    level = db.execute("SELECT * FROM levels WHERE id = ?", level_id.to_i).first
    completions = Completions.completions_of_level(level_id)
    attempts = Completions.level_attempts(level_id)
    erb :"levels/index", :locals => {:level => level, :completions => completions, :attempts => attempts}
  end

  post "", :loggedIn => "/" do
    user_id = session[:user][:id]
    level_id = params[:level_id]
    percentage = params[:percentage].to_f.clamp(0, 100)
    attempts = params[:attempts].to_i - Completions.level_attempts_by_user(level_id, user_id)
    perceived_difficulty = params[:perceived_difficulty].to_i
    created_at = Time.now.to_s

    completion_id = Completions.new_completion(user_id, level_id, percentage, attempts, perceived_difficulty, created_at)

    ActivityFeed.new_activity(user_id, "New Completion", "User has completed a level", "0", created_at)

    redirect("/users/#{user_id}")
  end
end