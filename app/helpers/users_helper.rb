module UsersHelper
  def ensure_user_editable
    unless @user.editable?
      redirect_to users_path, flash: {notice: t('model_not_editable', model: User.model_name.human)}
    end
  end
end
