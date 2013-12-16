class SessionsController < ApplicationController
  skip_before_filter :ensure_logged_in

  def new
    if other_auth_providers.size == 1 && !password_auth_provider?
      redirect_to "/auth/#{other_auth_providers.first[:provider]}"
    end
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.find_by_email(auth['uid'])
    if user.nil?
      flash.now[:notice] = t('.user_does_not_exist')
      render action: :new, status: 403
    else
      user.ensure_employment_exists
      sign_in(user)
      redirect_to user_time_entries_path(user)
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  def failure
    flash.now[:notice] = t('.login_failed')
    render action: :new, status: 403
  end
end
