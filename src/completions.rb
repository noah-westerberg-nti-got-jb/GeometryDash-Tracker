require_relative '../models/Levels'

require 'json'

App.namespace "/completions" do 
  get "/new", :loggedIn => "/" do
    erb :"completions/new"
  end

  post "", :loggedIn => "/" do
    level_id = params[:level_id]

    if !Levels.level_by_ingame_id(level_id)
      redirect("/levels/new?p=#{params.to_json}&l=#{level_id}")
    end

    user_id = session[:user][:id]
    percentage = params[:percentage].to_f.clamp(0, 100)
    attempts = params[:attempts].to_i - Completions.level_attempts_by_user(level_id, user_id)
    perceived_difficulty = params[:perceived_difficulty].to_i
    created_at = Time.now.to_s

    completion_id = Completions.new_completion(user_id, level_id, percentage, attempts, perceived_difficulty, created_at)

    ActivityFeed.new_activity(user_id, "New Completion", "User has completed a level", "0", created_at)

    redirect("/users/#{user_id}")
  end
end