class RideType < ActiveHash::Base
  include ActiveHash::Associations

  has_many :routes

  self.data = [
      {id: 1, title: 'User'},
      {id: 2, title: 'Butler'},
      {id: 3, title: 'Road'},
      {id: 4, title: 'G1'},
      {id: 5, title: 'BDR'}
  ]

end
