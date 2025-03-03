class App < Sinatra::Base
    configure do
        register Sinatra::Namespace

        set :public_folder, 'public'
        set :views, 'views'
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    def db
        return @db if @db
        
        @db = SQLite3::Database.new("db/GDTracker.sqlite")
        @db.results_as_hash = true
        
        return @db
    end

    def display_user_panel(user_id, info, content)
        user = db.execute('SELECT * FROM users WHERE id = ?', [user_id]).first
        erb :'utils/user_panel', :locals => {:user => user, :info => info, :content => content}
    end

    def display_activity_feed()
        erb :'utils/activity_feed', :layout => false
    end

    get '/' do
        erb :index
    end 
end

require_relative 'src/admin'
require_relative 'src/account'
require_relative 'src/activity_feed'