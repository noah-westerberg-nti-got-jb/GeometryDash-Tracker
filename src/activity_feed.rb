App.namespace '/activities' do 
  post '/', :loggedIn => "/account/login" do
    @db.execute('INSERT INTO activities (user_id, title, content, attatchment, created_at) VALUES (?, ?, ?, ?, ?)', [session[:user][:id], params[:title], params[:content], params[:attatchment], Date.now.to_s])

    redirect(params['redirect']) if params['redircet']
    redirect('/')
  end

  get '/delete/:id' do |id|
    @db.execute('DELETE FROM activities WHERE id = ?', id)

    redirect(params['redirect']) if params['redirect']
    redirect('/')
  end
end

class App
  def display_activity_feed(ids)
    if !ids.empty?
        @activities = db.execute('SELECT * FROM activities WHERE id IN (?)', [ids])
    end
    erb :'utils/activity_feed', :layout => false
  end
end