App.set(:isAdmin) do |redirect|
    condition do
        if session[:user]
            return session[:user][:id] == 1
        end
        status 403
        redirect(redirect) if redirect
        return false
    end
end

App.namespace '/admin', :isAdmin => '/users/login' do
  get '' do 
      redirect('/admin/database')
  end

  get '/database' do
    @hide_header = true
    erb :'admin/database'
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
                    # Jag tycker inte att den här databas användningen behöver flyttas till en separat model-fil 
                    # eftersom det inte hade förenklat koden eller gjort den mer läsbar.
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
    @hide_header = true
    format_db_data(Users.all_users)
  end
end