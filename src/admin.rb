App.namespace '/admin', :isAdmin => '/login' do
  get '' do 
      redirect('/admin/database')
  end

  get '/database' do
      erb(:database)
  end

  def format_db_data(data) 
      output = ""
      data.each do |item|
          output += item.to_s + "<br>"
      end
      return output
  end

  get '/database-output/*' do |query_list|
      output = ""

      if query_list
          query_list.split(';').each do |query|
              output += "<strong>[" + query + "]:</strong><br><br>"
              
              begin
                  output += format_db_data(db.execute(query))
              rescue SQLite3::SQLException => e
                  output += e.to_s
              end

              output += "<br><br>"
          end
      end

      return output
  end
  
  get '/view-users' do
      format_db_data(db.execute('SELECT * FROM users'))
  end
end