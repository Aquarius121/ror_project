# == Schema Information
#
# Table name: conditions
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Condition < ActiveRecord::Base
  has_many :route 
end
