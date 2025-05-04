require_relative '../models/ActivityFeed'

App.namespace '/activities' do 
  # @route POST /activities
  # @condition :loggedIn Användaren måste vara inloggad
  # @param [String] redirect URL att omdirigera till efter skapande (valbar)
  # @return [Redirect] Omdirigerar till hemsidan eller den angivna redirect-URL:en
  post '/', :loggedIn => "/account/login" do
    # TODO: Create activities

    redirect(params['redirect']) if params['redircet']
    redirect('/')
  end

  # @route GET /activities/delete/:id
  # @param [Integer] id Aktivitets-ID för inlägget som ska raderas
  # @param [String] redirect URL att omdirigera till efter radering (valbar)
  # @return [Redirect] Omdirigerar till hemsidan eller den angivna redirect-URL:en
  get '/delete/:id' do |id|
    ActivityFeed.delete_activity(id)

    redirect(params['redirect']) if params['redirect']
    redirect('/')
  end
end

class App
  def display_activity_feed(user_ids)
    activities = ActivityFeed.activities_from_users(user_ids)
    p "activities: #{activities}"
    return erb :'activity_feed/index', :layout => false, :locals => { :activities => activities }
  end
end