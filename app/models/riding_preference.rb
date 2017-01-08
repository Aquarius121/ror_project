class RidingPreference < ActiveHash::Base
  include ActiveHash::Associations

  has_many :user_riding_preferences

  self.data = [
      {id: 1, title: "Sport" },
      {id: 2, title: "Cruiser" },
      {id: 3, title: "Adventure"},
      {id: 4, title: "Standard"},
      {id: 5, title: "Sport-Touring"},
      {id: 6, title: "Single Track"},
      {id: 7, title: "Cafe"},
      {id: 8, title: "Vintage"},
      {id: 9, title: "Side Car"},
      {id: 10, title: "Trike"},
      {id: 11, title: "Scooter"},
      {id: 12, title: "Electric"},
      {id: 13, title: "Bagger"}
  ]
end
