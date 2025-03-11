class App
  def display_user_panel(user_id, info, content)
    user = db.execute('SELECT * FROM users WHERE id = ?', [user_id]).first
    erb :'user_panel', :locals => {:user => user, :info => info, :content => content}
  end
end