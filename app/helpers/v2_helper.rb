module V2Helper
  def current_year
    Date.today.year
  end

  def support_link
    link_to 'help/support', 'http://rever.co/support/', target: :blank
  end

  def get_the_app_link
    link_to 'get the app', 'http://rever.co/download-app/', target: :blank
  end

  def logout_link
    link_to 'log out', destroy_user_session_path
  end

  def member_since_for user
    [user.role_title, user.created_at.to_s(:date)].join ' since '
  end

  def avatar_for instance
    content_tag :div, class: 'avatar' do
      image_tag instance.avatar_url
    end if instance.respond_to? :avatar_url and instance.avatar_url.present?
  end

  def plan_a_ride_link
    link_to new_v2_ride_path, class: 'b-header-actions' do
      content_tag(:i, '', class: 'icon-arrow-left') + 'Plan a ride'
    end
  end

  def dashboard_link
    link_to v2_root_path, class: 'b-header-actions' do
      content_tag(:i, '', class: 'icon-arrow-left') + 'To my dashboard'
    end
  end

  def back_to_group_link club
    link_to v2_club_path(club), class: 'b-header-actions' do
      content_tag(:i, '', class: 'icon-arrow-left') + 'Back to group'
    end
  end

  def available_timezones
    ActiveSupport::TimeZone.zones_map.values.map &:to_s
  end
end
