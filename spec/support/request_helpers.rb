module RequestHelpers
  def login(user)
    user.update_attribute(:uid, 'user1')
    visit root_path
  end
end
