# == Schema Information
#
# Table name: club_types
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ClubType < ActiveRecord::Base
  has_many :clubs
end

# class ClubType < ActiveHash::Base
#   include ActiveHash::Associations
#
#   has_many :clubs
#
#   self.data = [
#       {id: 1, title: 'Club'},
#       {id: 2, title: 'Company'},
#       {id: 3, title: 'Shop'},
#       {id: 4, title: 'Event'},
#       {id: 5, title: 'Other'}
#   ]
# end
