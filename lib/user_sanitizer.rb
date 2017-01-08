class User::ParameterSanitizer < Devise::ParameterSanitizer
    private
    def account_update
        default_params.permit(:firstname, :lastname, :address, :city, :state,
                              :zip, :country, :motorcycle_club, :email,
                              :password, :password_confirmation,
                              :current_password, :fb_id, :fb_token)
    end
end
