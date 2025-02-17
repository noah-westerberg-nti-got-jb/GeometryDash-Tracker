class App < Sinatra::Base
    configure do
        register Sinatra::Namespace

        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    def db
        return @db if @db
        
        @db = SQLite3::Database.new("db/GDTracker.sqlite")
        @db.results_as_hash = true
        
        return @db
    end

    get '/' do
        erb(:index)
    end

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
    set(:isAdmin) do |redirect|
        condition do
            unless session[:user] && session[:user][:id] == 1
                status 403
                redirect(redirect)
            end
        end
    end

    namespace '/admin', :isAdmin => '/' do
        get '' do
            erb(:admin)
        end
    end
end