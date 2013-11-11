class UserRole
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :role, :user_id, :resource

  def create
    user.add_role :role, resource
  end

  def user
    @user ||= User.find user_id
  end

  def user=
    @user = user
    self.user_id = user.id
  end

  def persisted?
    false
  end
end
