App.namespace '/activities' do 
  post '/new', :loggedIn => "/account/login" do
    @db.execute('INSERT INTO activity_feed (user_id, title, content, attatchment, created_at) VALUES (?, ?, ?, ?, ?)', [session[:user][:id], params[:title], params[:content], params[:attatchment], Date.now.to_s])

    redirect[params['redirect']] if params['redircet']
    redirect('/')
  end

  get '/delete/:id' do |id|
    @db.execute('DELETE FROM activity_feed WHERE id = ?', id)

    redirect[params['redirect']] if params['redirect']
    redirect('/')
  end
end