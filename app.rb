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

    set(:isAdmin) do |redirect|
        condition do
            unless session[:user] && session[:user][:id] == 1
                status 403
                redirect(redirect)
            end
        end
    end

    namespace '/admin', :isAdmin => '/login' do
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
end