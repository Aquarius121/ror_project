class Surface < ActiveHash::Base
  include ActiveHash::Associations

  has_many :routes

  self.data = [
      {id: 1, title: 'Dirt'},
      {id: 2, title: 'Paved'},
      {id: 3, title: 'Dual Sport'},
      {id: 4, title: 'Singletrack'},
      {id: 5, title: 'Track'}
  ]
end
