require_relative '../models/Levels'

require 'json'

App.namespace "/completions" do 
  # @route GET /completions/new
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [String] HTML-formulär för att registrera en ny completion
  get "/new", :loggedIn => "/" do
    erb :"completions/new"
  end

  # @route POST /completions
  # @param [Integer] level_id ID för leveln som slutförts
  # @param [Float] percentage Hur stor del av leveln som klarats av (0-100)
  # @param [Integer] attempts Antal försök som gjorts
  # @param [Integer] perceived_difficulty Upplevd svårighetsgrad (-3 till 3)
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar till användarens profilsida
  # @return [Redirect] Omdirigerar till formulär för att skapa ny level om leveln inte finns
  post "", :loggedIn => "/" do
    level_id = params[:level_id]

    if !Levels.level_by_id(level_id)
      redirect("/levels/new?p=#{params.to_json}&l=#{level_id}")
    end

    user_id = session[:user][:id]
    percentage = params[:percentage].to_f.clamp(0, 100)
    attempts = params[:attempts].to_i - Completions.level_attempts_by_user(level_id, user_id)
    perceived_difficulty = params[:perceived_difficulty].to_i
    created_at = Time.now.to_s

    completion_id = Completions.new_completion(user_id, level_id, percentage, attempts, perceived_difficulty, created_at)

    ActivityFeed.new_activity(user_id, "New Completion", "User has completed a level", completion_id, created_at)

    redirect("/users/#{user_id}")
  end
end