class Privacy < ActiveHash::Base
  include ActiveHash::Associations

  has_many :routes
  has_many :clubs

  self.data = [
      {id: 1, title: 'Private'},
      {id: 2, title: 'Public'},
      # {id: 3, title: 'Friends Only'}
  ]
end
