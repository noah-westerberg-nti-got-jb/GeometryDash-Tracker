require_relative '../models/Collections'

App.namespace '/collections' do
  
  get '' do 
    erb :"collections/index", :locals => {:collections => Collections.all}
  end

  get '/:id' do |id|
      erb :"collections/show", :locals => {:collection_levels =>  Collections.by_id_with_levels(id)}

  end 
end