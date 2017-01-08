module Admin

  class UserSessionsController < ApplicationController
    def create
      user = User.find(params[:user_id])
      session[:original_admin_user_id] = current_user.id
      sign_in(:user, user, {bypass: true}) # do not change last_sign_in_at
      redirect_to root_path, notice: 'Signed in successfully'
    end

    def destroy
      sign_in(:user, session[:original_admin_user_id], {bypass: true})
      session.delete(:original_admin_user_id)
      redirect_to root_path, notice: 'Signed out successfully'
    end
  end

end
