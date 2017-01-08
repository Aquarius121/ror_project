class SilentPostController < ActionController::Base
  # Every time Authorize.net sends card to process (it means that the card is not expired,
  # has valid number, etc), it posts the result of the processing to a configurable url of your app.
  # It is strongly required to postpone any work with that data and just sump it to DB (the request must take less than 2sec and result in 2xx http code)
  # If the request fails - that data is lst, as Authorize.net would not attempt to resend it.
  def save_to_db
    CardTransaction.create(raw_data: request.raw_post)
    render :nothing => true, :status => 200
  end
end
