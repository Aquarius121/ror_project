class UserFilter < ActiveHash::Base
  include ActiveHash::Associations
  belongs_to :bike_type
  fields :name, :location, :bike_type_id

  def empty?
    [self.name, self.location, self.bike_type_id].all? {|field| field.blank?}
  end
end
