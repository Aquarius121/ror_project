# == Schema Information
#
# Table name: activities
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  follower_id   :integer
#  activity_date :date
#  activity_text :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Activity < ActiveRecord::Base
  belongs_to :follower, :class_name => "User", :foreign_key => "follower_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"

  def self.add_activity(template, args, user_id, follower_id = nil)
    text = ActionController::Base.new.render_to_string(partial: template, locals: {args: args})
    Activity.create(
        :activity_date => Time.now.strftime("%Y-%m-%d"),
        :activity_text => text,
        :user_id => user_id,
        :follower_id => follower_id
    )
  end

  def self.for_user(user)
    friends =  Friendship.list_friends(user)
    Activity.where(['(user_id IN (?) AND follower_id IS NULL) OR follower_id = ?', friends, user ]).distinct(:id).order(id: :desc).limit(10)
  end

end
