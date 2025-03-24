App.namespace "/levels" do 
    get "/new", :loggedIn => "/" do
      erb :"levels/new"
    end
  
  get "/:level_id" do |level_id|
    level = db.execute("SELECT * FROM levels WHERE id = ?", level_id.to_i).first
    completions = Completions.new(db).level_completions(level_id)
    attempts = Completions.new(db).level_attempts(level_id)
    erb :"levels/index", :locals => {:level => level, :completions => completions, :attempts => attempts}
  end

  post "", :loggedIn => "/" do
    user_id = session[:user][:id]
    level_id = params[:level_id]
    percentage = params[:percentage].to_f.clamp(0, 100)
    attempts = params[:attempts].to_i - Completions.new(db).level_attempts_by_user(level_id, user_id)
    perceived_difficulty = params[:perceived_difficulty].to_i
    created_at = Time.now.to_s

    Completions.new(db).new_completion(user_id, level_id, percentage, attempts, perceived_difficulty, created_at)
    redirect("/users/#{user_id}")
  end
end