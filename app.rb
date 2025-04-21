require_relative 'models/Completions'
require_relative 'models/Users'
require_relative 'models/FollowList'

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
        @db.execute('PRAGMA foreign_keys = ON')
        
        return @db
    end

    def header_hidden? 
        if @hide_header
            @hide_header = false
            return true
        end
        return false
    end

    get '/' do
        erb :index
    end 

    get '/leaderboard' do
        users = Users.users_by_score
        erb :leaderboard, :locals => {:users => users} 
    end
end

require_relative 'src/admin'
require_relative 'src/account'
require_relative 'src/activity_feed'
require_relative 'src/user_panel'
require_relative 'src/levels'
require_relative 'src/completions'