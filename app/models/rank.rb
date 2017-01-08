# == Schema Information
#
# Table name: ranks
#
#  id           :integer          not null, primary key
#  challenge_id :integer
#  user_id      :integer
#  rank         :integer
#  total_data   :float
#  created_at   :datetime
#  updated_at   :datetime
#

class Rank < ActiveRecord::Base
  belongs_to :user
  belongs_to :challenge
end
