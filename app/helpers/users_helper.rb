module UsersHelper
  def ensure_assigned_user_editable
    @user.when_not_editable do
      redirect_to users_path, flash: {notice: t('model_not_editable', model: User.model_name.human)}
    end
  end
end
