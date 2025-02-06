class App < Sinatra::Base

    def db
        return @db if @db

        @db = SQLite3::Database.new("db/GDTracker.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        erb(:index)
    end

    get '/db-test' do 
        db.execute('SELECT * FROM users').to_s
    end
end