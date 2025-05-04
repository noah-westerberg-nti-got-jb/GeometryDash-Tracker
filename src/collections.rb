require_relative '../models/Collections'

App.namespace '/collections' do
  
  # @route POST /collections
  # @param [String] name Namn på den nya samlingen
  # @param [String] description Beskrivning av samlingen (valbar)
  # @param [String] level_id Level att lägga till i samlingen (valbar)
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar till den nya samlingens sida
  post '', :loggedIn => "/collections"  do
    collection_id = Collections.new(session[:user][:id], params['name'], params['description'])
    if params['level_id'] != ""
      Collections.add_level(collection_id, params['level_id'])
    end
    redirect("/collections/#{collection_id}")
  end

  # @route GET /collections
  # @return [String] HTML-sida som visar alla samlingar
  get '' do 
    erb :"collections/index", :locals => {:collections => Collections.all}
  end

  # @route GET /collections/:id
  # @param [Integer] id Samlingens ID
  # @return [String] HTML-sida som visar samlingens innehåll
  get '/:id' do |id|
    erb :"collections/show", :locals => {:collection_levels =>  Collections.by_id_with_levels(id)}
  end 

  # @route POST /collections/:id/delete
  # @param [Integer] id ID för samlingen som ska raderas
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar till samlingslistan
  post '/:id/delete', :loggedIn => "/collections" do |id|
    Collections.delete(id)
    redirect("/collections")
  end

  # @route POST /collections/:collection_id/add/:level_id
  # @param [Integer] collection_id ID för samlingen
  # @param [Integer] level_id ID för leveln som ska läggas till
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar tillbaka till samlingens sida
  post '/:collection_id/add/:level_id', :loggedIn => "/collections" do |collection_id, level_id|
    Collections.add_level(collection_id, level_id)
    redirect("/collections/#{collection_id}")
  end

  # @route POST /collections/:collection_id/remove/:level_id
  # @param [Integer] collection_id ID för samlingen
  # @param [Integer] level_id ID för leveln som ska tas bort
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar tillbaka till samlingens sida
  post '/:collection_id/remove/:level_id', :loggedIn => "/collections" do |collection_id, level_id|
    Collections.remove_level(collection_id, level_id)
    redirect("/collections/#{collection_id}")
  end

  # @route GET /collections/:id/collections/new
  # @param [Integer] id Användar-ID
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [String] HTML-formulär för att skapa ny samling
  get '/:id/collections/new', :loggedIn => "/collections" do
    erb :"collections/new"
  end
end