class Role < ActiveHash::Base
  include ActiveHash::Associations

  fields :name, :title

  has_many :users

  self.data = [
      {id: 1, name: 'Admin',  title: 'Admin user'      },
      {id: 2, name: 'Free',   title: 'Standard member' },
      {id: 3, name: 'Pro',    title: 'Pro member'      },
      {id: 4, name: 'Plus',   title: 'Plus member'     } # TODO isn't it obsolete?
  ]
end
