module Extended
  def route name, *params
    Rails.application
      .routes
      .url_helpers
      .send name, *params
  end
end
