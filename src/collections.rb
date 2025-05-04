require_relative '../models/Collections'

App.namespace '/collections' do
  
  get '' do 
    erb :"collections/index", :locals => {:collections => Collections.all}
  end

  get '/:id' do |id|
      erb :"collections/show", :locals => {:collection_levels =>  Collections.by_id_with_levels(id)}

  end 

  post '/:id/delete', :loggedIn => "/collections" do |id|
    Collections.delete(id)
    redirect("/collections")
  end

  post '/:collection_id/add/:level_id', :loggedIn => "/collections" do |collection_id, level_id|
    Collections.add_level(collection_id, level_id)
    redirect("/collections/#{collection_id}")
  end

  post '/:collection_id/remove/:level_id', :loggedIn => "/collections" do |collection_id, level_id|
    Collections.remove_level(collection_id, level_id)
    redirect("/collections/#{collection_id}")
  end
end