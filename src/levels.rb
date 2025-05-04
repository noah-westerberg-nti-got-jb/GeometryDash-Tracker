App.namespace "/levels" do 
  # @route GET /levels/new
  # @param [String] p JSON-data för completion-formuläret (valbar)
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [String] HTML-formulär för att skapa ny level
  get '/new', :loggedIn => "/" do
    erb :"levels/new", :locals => {:p => params[:p]}
  end

  # @route POST /levels
  # @param [Integer] level_id ID för den nya leveln
  # @param [String] name Levelns namn
  # @param [String] difficulty Levelns svårighetsgrad
  # @param [String] length_text Levelns längd som text
  # @param [String] p JSON-data för completion-formuläret (valbar)
  # @return [Redirect] Omdirigerar till completion-formuläret eller hemsidan
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

  # @route GET /levels/:level_id
  # @param [Integer] level_id ID för leveln som ska visas
  # @return [String] HTML-sida som visar levelns information och statistik
  get "/:level_id" do |level_id|
    level = Levels.level_by_id(level_id)
    completions = Completions.completions_of_level(level['id'])
    attempts = Completions.level_attempts(level['id'])
    collections = Collections.by_level_id(level['id'])
    erb :"levels/show", :locals => {:level => level, :completions => completions, :attempts => attempts, :collections => collections}
  end

  # @route GET /levels
  # @param [String] search Sökterm för att hitta levels (valbar)
  # @return [String] HTML-sida som visar alla levels eller sökresultat
  get '' do 
    if params[:search] != ""
      level_by_id = Levels.level_by_id(params[:search])
      level_by_name = Levels.level_by_name(params[:search])
      levels = [level_by_id, level_by_name].compact
      p levels
    end

    levels = Levels.all if !levels || levels.empty?
    

    erb :"levels/index", :locals => {:levels => levels}
  end
end