class ClubFilter < ActiveHash::Base
  include ActiveHash::Associations
  belongs_to :club_type

  fields :name, :location, :club_type_id

  def empty?
    [self.name, self.location, self.club_type_id].all? {|field| field.blank?}
  end
end
