require_relative "../models/Users"
require_relative "../models/Completions"
require_relative "../models/FollowList"

App.set(:loggedIn) do |redirect|
    condition do
        if session[:user]
            true
        else
            redirect(redirect) if redirect
            false
        end
    end
end

App.namespace '/users' do

  # @route GET /users/login
  # @param [String] redirect En sträng med routen som ska återvändas till efter inloggningen. Om inget värde ges, så skickas användaren till '/'.
  get '/login' do
    session[:login_attempts] = 0 if !session[:login_attempts]

    redirect = nil
    redirect = params['redirect'] if params['redirect']

    @hide_header = true
    erb :'account/login', :locals => {:redirect => redirect}
  end

  # @route POST /login
  # @param [String] username Användarnamn för inloggning
  # @param [String] password Lösenord för inloggning
  # @param [String] redirect URL att omdirigera till vid lyckad inloggning (valbar)
  # @return [Redirect] Vid lyckad inloggning omdirigeras användaren till `/` eller den angivna redirect-URL:en
  # @return [String] HTML-inloggningssida om inloggningen misslyckas
  post '/login' do
      user = Users.user_by_name(params[:username])

      if user
          hashed_password = BCrypt::Password.new(user['password'])
          if hashed_password == params[:password]
              session[:user] = {:id => user['id'].to_i, :name => user['username']}
              session[:login_attempts] = 0

              session[:login_attempts] = 0

              redirect(params['redirect']) if params['redirect']
              redirect('/')
          end
      end

      session[:login_attempts] += 1

      status 400
      redirect("/users/login?redirect=#{params['redirect']}") if params['redirect']
      redirect('/users/login')
  end

  # @route GET /users/new
  # @param [String] redirect URL att omdirigera till efter registrering (valbar)
  # @return [String] HTML-registreringsformulär
  get '/new' do
      redirect = nil
      redirect = params['redirect'] if params['redirect']
      @hide_header = true
      erb :'account/new', :locals => {:redirect => redirect}
  end

  # @route POST /users
  # @param [String] username Användarnamn för den nya användaren
  # @param [String] password Lösenord för den nya användaren
  # @param [String] redirect URL att omdirigera till efter registrering (valbar)
  # @return [Redirect] Omdirigerar till inloggningssidan vid lyckad registrering
  # @return [Redirect] Omdirigerar tillbaka till registreringsformuläret vid fel
  post '/' do
      if !Users.create_user(params[:username], params[:password])
          status 400
          redirect('/users/new')
      end
      redirect("/users/login?redirect=#{params['redirect']}") if params['redirect']
      redirect('/users/login')
  end

  # @route GET /users
  # @return [Redirect] Omdirigerar användaren till leaderboard-sidan
  get '' do 
    redirect("/leaderboard")
  end

  # @route GET /users/
  # @return [Redirect] Omdirigerar användaren till leaderboard-sidan  
  get '/' do 
    redirect("/leaderboard")
  end

  # @route GET /users/logout
  # @param [String] redirect URL att omdirigera till efter utloggning (valbar)
  # @return [Redirect] Omdirigerar användaren till hemsidan eller den angivna redirect-URL:en
  get '/logout' do
      session[:user] = nil
      
      redirect(params['redirect']) if params['redirect']
      redirect('/')
  end

  # @route GET /users/:id
  # @param [Integer] id Användar-ID för profilen som ska visas
  # @return [String] HTML-sida med användarens profil och statistik
  # @return [String] Felmeddelande om användaren inte hittas (404)
  get '/:id' do |id|
    user = Users.user_by_id(id)
    
    if !user
      status 404
      return erb :'account/unkown', :locals => {:id => id}
    end

    completions = Completions.completions_by_user(id)
    follower_count = FollowList.get_follower_count(id)
    following_count = FollowList.get_following_count(id)

    erb :'account/show', :locals => {:user => user, :completions => completions, :follower_count => follower_count, :following_count => following_count}
  end

  # @route POST /users/:id/delete
  # @param [Integer] id Användar-ID för kontot som ska raderas
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar till hemsidan efter radering
  post '/:id/delete', :loggedIn => "/" do |id|
    redirect('/') unless session[:user][:id] == id.to_i
    Users.delete_user(id)
    session[:user] = nil
    redirect('/')
  end

  # @route POST /users/:id/update
  # @param [Integer] id Användar-ID för kontot som ska uppdateras
  # @param [String] username Det nya användarnamnet
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar till inloggningssidan vid lyckad uppdatering
  # @return [Redirect] Omdirigerar till redigeringssidan med felmeddelande om användarnamnet är upptaget
  post '/:id/update', :loggedIn => "/" do |id|
    redirect('/') unless session[:user][:id] == id.to_i
    
    redirect("/users/#{id}/edit?error=username is not available") unless Users.change_username(id, params[:username])
    session[:user] = nil
    redirect('users/login')
  end

  # @route GET /users/:id/edit
  # @param [Integer] id Användar-ID för kontot som ska redigeras
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [String] HTML-formulär för att redigera användaruppgifter
  get '/:id/edit', :loggedIn => "/" do |id|
    redirect('/') unless session[:user][:id] == id.to_i
    user = Users.user_by_id(id)
    erb :'account/edit', :locals => {:user => user}
  end

  # @route POST /users/:id/follow
  # @param [Integer] id Användar-ID för användaren som ska följas
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar tillbaka till den följda användarens profilsida
  post '/:id/follow', :loggedIn => "/" do |id|
    FollowList.follow(session[:user][:id], id)
    # TODO: Add message if it fails
    redirect("/users/#{id}")
  end

  # @route POST /users/:id/unfollow
  # @param [Integer] id Användar-ID för användaren som ska avföljas
  # @condition :loggedIn Användaren måste vara inloggad
  # @return [Redirect] Omdirigerar tillbaka till den avföljda användarens profilsida
  post '/:id/unfollow', :loggedIn => "/" do |id|
    FollowList.unfollow(session[:user][:id], id)
    redirect("/users/#{id}")
  end

  # @route GET /users/:id/followers
  # @param [Integer] id Användar-ID för att hämta följarlistan
  # @return [String] HTML-sida som visar alla användare som följer den angivna användaren
  get '/:id/followers' do |id|
    user = Users.user_by_id(id)
    erb :"account/follow_list", :locals => {:users => FollowList.get_followers(id), :title => "Users following <a href=\\\"/users/#{id}\\\"><em>#{user['username']}##{user['id']}</em></a>"}
  end

  # @route GET /users/:id/following
  # @param [Integer] id Användar-ID för att hämta listan över följda användare
  # @return [String] HTML-sida som visar alla användare som den angivna användaren följer
  get '/:id/following' do |id|
    user = Users.user_by_id(id)
    erb :"account/follow_list", :locals => {:users => FollowList.get_following(id), :title => "Users <a href=\\\"/users/#{id}\\\"><em>#{user['username']}##{user['id']}</em></a> is following"}
  end

  # @route GET /users/:id/collections 
  # @param [Integer] id Användar-ID för att hämta användarens samlingar
  # @return [String] HTML-sida med en lista över användarens samlingar
  get '/:id/collections' do |id|
    erb :"collections/index", :locals => {:collections => Collections.by_user(id)}
  end
end