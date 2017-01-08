class EmbedController < ActionController::Base
  layout :resolve_layout

  def index
    @route = Route.find(params[:route_id])
    if @route.private?
      redirect_to '/', :notice => 'This route is private.'
    elsif params[:fb_action_ids]
      redirect_to '/?from-fb-embedded-page'
    else
      response.headers['X-Frame-Options'] = 'ALLOWALL'
    end
  end

  def shot
    @route = Route.find(params[:route_id])
  end

  private

  def resolve_layout
    case action_name
      when 'index'
        'embedded'
      when 'shot'
        'shot'
      else
        'application'
    end
  end
end