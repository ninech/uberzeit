include SessionsHelper

def test_sign_in(person = nil)
  person ||= Person.find_one
  sign_in(person.id)
  current_user
end
