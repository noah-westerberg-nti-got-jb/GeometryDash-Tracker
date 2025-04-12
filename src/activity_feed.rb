App.namespace '/activities' do 
  post '/', :loggedIn => "/account/login" do
    # TODO: Create activities

    redirect(params['redirect']) if params['redircet']
    redirect('/')
  end

  get '/delete/:id' do |id|
    ActivityFeed.delete_activity(id)

    redirect(params['redirect']) if params['redirect']
    redirect('/')
  end
end

class App
  def display_activity_feed(user_ids)
    activities = ActivityFeed.activities_from_users(user_ids)
    erb :'activity_feed/index', :layout => false, locales: { activities: activities }
  end
end