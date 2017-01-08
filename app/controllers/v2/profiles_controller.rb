class V2::ProfilesController < V2Controller
  def update
    if current_user.update_with_password profile_params
      sign_in current_user, bypass: true
      redirect_to action: :show
    else
      render :show
    end
  end

  private
  def profile_params
    # TODO filter params
    params.require(:user).permit!
    # user_riding_preference_ids: []
  end
end
