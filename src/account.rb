App.namespace '/account' do
  get '/login' do
    erb(:login)
  end

  post '/login' do
      user = db.execute('SELECT * FROM users WHERE username = ?', [params[:username]]).first

      if user
          hashed_password = BCrypt::Password.new(user['password'])
          if hashed_password == params[:password]
              session[:user] = {:id => user['id'].to_i, :name => user['username']}
              redirect('/')
          end
      end

      status 400
      redirect('/login')
  end

  get '/create-account' do
      erb(:create_account)
  end

  post '/create-account' do
      if db.execute('SELECT username FROM users WHERE username = ?', [params[:username]]).first
          status 400
          redirect('/create-account')
      end

      hashed_password = BCrypt::Password.create(params[:password])
      db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [params[:username], hashed_password])
      redirect('/login')
  end
end

App.set(:loggedIn) do |redirect|
    condition do
        redirect(redirect) unless session[:user]   
    end
end