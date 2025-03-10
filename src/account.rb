App.namespace '/users' do
  get '/login' do
    @hide_header = true
    erb :'account/login'
  end

  post '/login' do
      user = db.execute('SELECT * FROM users WHERE username = ?', [params[:username]]).first

      if user
          hashed_password = BCrypt::Password.new(user['password'])
          if hashed_password == params[:password]
              session[:user] = {:id => user['id'].to_i, :name => user['username']}

              redirect(params['redirect']) if params['redirect']
              redirect('/')
          end
      end

      status 400
      redirect('/login')
  end

  get '/new' do
      @hide_header = true
      erb :'account/create_account'
  end

  post '/' do
      if db.execute('SELECT username FROM users WHERE username = ?', [params[:username]]).first
          status 400
          redirect('/create-account')
      end

      hashed_password = BCrypt::Password.create(params[:password])
      db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [params[:username], hashed_password])
      redirect('/login')
  end

  get '/logout' do
      session[:user] = nil
      
      redirect(params['redirect']) if params['redirect']
      redirect('/')
  end

  get '/:id' do |id|
    user = db.execute('SELECT * FROM users WHERE id = ?', [id]).first
    completions = db.execute('SELECT * FROM completions WHERE user_id = ?', [id])
    erb :'account/profile', :locals => {:user => user, :completions => completions}
  end
end

App.set(:loggedIn) do |redirect|
    condition do
        redirect(redirect) unless session[:user]   
    end
end