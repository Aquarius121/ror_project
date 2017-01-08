class HomepageController < ApplicationController
  def index
    @route = Route.new
    if session[:signup_error]
      @signup_error = session[:signup_error]
      session.delete(:signup_error)
    end
  end
end
