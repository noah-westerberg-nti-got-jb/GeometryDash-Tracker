App.namespace '/activity' do 
  post '/new/*', :loggedIn => "/account/login" do
    @db.execute('INSERT INTO activity_feed (user_id, title, content, attatchment, created_at) VALUES (?, ?, ?, ?, ?)', [session[:user][:id], params[:title], params[:content], params[:attatchment], Date.now.to_s])

    redirect[params['splat'][0]] if params['splat'][0]
    redirect('/home')
  end

  get '/delete/:id/*' do |id|
    @db.execute('DELETE FROM activity_feed WHERE id = ?', id)

    redirect[params['splat'][0]] if params['splat'][0]
    redirect('/home')
  end

end