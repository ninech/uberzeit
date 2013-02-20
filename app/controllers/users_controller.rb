class UsersController < ApplicationController
  def index
    render :text => 'Users#index'
  end

  def show
    render :text => 'Users#show'
  end
end
