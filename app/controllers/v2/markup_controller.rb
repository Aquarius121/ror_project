class V2::MarkupController < V2Controller
  layout 'v2-markup'

  def index
    redirect_to v2_markup_dashboard_path
  end
end
