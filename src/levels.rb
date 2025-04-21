App.namespace "/levels" do 
  get '/new', :loggedIn => "/" do
    erb :"levels/new", :locals => {:p => params[:p]}
  end

  post '' do
    level_id = params['level_id']
    name = params['name']
    difficulty = params['difficulty']
    length_text = params['length_text']

    Levels.new(level_id, name, difficulty, length_text)

    if !params[:p]
      redirect("/")
    end

    redirect("/completions/new?p=" + params[:p].to_s)
  end

  get "/:level_id" do |level_id|
    level = Levels.level_by_id(level_id)
    completions = Completions.completions_of_level(level['ingame_id'])
    attempts = Completions.level_attempts(level['ingame_id'])
    erb :"levels/index", :locals => {:level => level, :completions => completions, :attempts => attempts}
  end
end