class BikeType < ActiveHash::Base
  include ActiveHash::Associations

  has_many :routes

  self.data = [
      {id: 1, title:  'Sportbike'},
      {id: 2, title:  'Cruiser'},
      {id: 3, title:  'Adventure Bike'},
      {id: 4, title:  'standard'},
      {id: 5, title:  'Sport Touring'},
      {id: 6, title:  'naked bike'},
      {id: 7, title:  'Enduro (not street legal)'},
      {id: 8, title:  'Cafe racer'},
      {id: 9, title:  'Vintage'},
      {id: 10, title:  'Side Car'},
      {id: 11, title:  'Trike'}
  ]
end
