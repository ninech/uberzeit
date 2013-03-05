include SessionsHelper

def test_sign_in(user = nil)
  user ||= FactoryGirl.create(:user)
  sign_in(user)
  current_user
end
