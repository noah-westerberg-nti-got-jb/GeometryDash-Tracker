require_relative "../models/Users"
require_relative "../models/Completions"

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
  get '/login' do
    session[:login_attempts] = 0 if !session[:login_attempts]

    @hide_header = true
    erb :'account/login'
  end

  post '/login' do
      user = Users.user_by_name(params[:username])

      if user
          hashed_password = BCrypt::Password.new(user['password'])
          if hashed_password == params[:password]
              session[:user] = {:id => user['id'].to_i, :name => user['username']}
              session[:login_attempts] = 0

              redirect(params['redirect']) if params['redirect']
              redirect('/')
          end
      end

      session[:login_attempts] += 1

      status 400
      redirect('/users/login')
  end

  get '/new' do
      @hide_header = true
      erb :'account/create_account'
  end

  post '/' do
      if !Users.create_user(params[:username], params[:password])
          status 400
          redirect('/users/new')
      end
      redirect('/users/login')
  end

  get '/logout' do
      session[:user] = nil
      
      redirect(params['redirect']) if params['redirect']
      redirect('/')
  end

  get '/:id' do |id|
    user = Users.user_by_id(id)
    completions = Completions.completions_by_user(id)

    if session[:user] && session[:user][:id] == id.to_i
      erb :'account/profile_self', :locals => {:user => user, :completions => completions}
    else
      erb :'account/profile', :locals => {:user => user, :completions => completions}
    end
  end

  post '/:id/delete', :loggedIn => "/" do |id|
    redirect('/') unless session[:user][:id] == id.to_i
    Users.delete_user(id)
    session[:user] = nil
    redirect('/')
  end

  post '/:id/edit', :loggedIn => "/" do |id|
    redirect('/') unless session[:user][:id] == id.to_i
    
    redirect("/users/#{id}/edit?error=username is not available") unless Users.change_username(id, params[:username])
    session[:user] = nil
    redirect('users/login')
  end

  get '/:id/edit', :loggedIn => "/" do |id|
    redirect('/') unless session[:user][:id] == id.to_i
    user = Users.user_by_id(id)
    erb :'account/edit', :locals => {:user => user}
  end
end