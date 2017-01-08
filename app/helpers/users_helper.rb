module UsersHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def location_state(addr)
    addr == nil ? addr = ' ' : addr = addr
    addr.split(', ')[0]
  end

  def location_city(addr)
    addr == nil ? addr = ' ' : addr = addr
    addr.split(', ')[1]
  end

  def location_cities(state)
    cities = JSON.parse(open('app/assets/json/cities-per-state.json').read)[state]
    if cities.blank?
      Array.new()
    else
      cities.collect { |val| [val, val] }
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end


end