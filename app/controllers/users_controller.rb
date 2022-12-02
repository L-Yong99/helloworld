class UsersController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def destroy
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.update(user_params)
    redirect_to edit_user_path(current_user)
  end

  private

  def user_params
    params.require(:user).permit(:first_name,:last_name,:email,:image)
  end

end
