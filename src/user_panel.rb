class App
  def display_user_panel(user_id, info, content)
    user = Users.user_by_id(user_id)
    if (user.nil?)
      return
    end
    return erb :'utils/user_panel', :locals => {:user => user, :info => info, :content => content}
  end
end