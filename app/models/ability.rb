class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    alias_action :promote_to_admin, :demote_to_free, :make_pro, :to => :promote

    user ||= User.new


    if user.role? :free
      can :manage, :all
      cannot :download, Route
      cannot :index, User
      cannot :promote, User
      # cannot :manage, :friendship
      # cannot :searchbutler, :route
      cannot :copy, Route
      cannot :manage, Coupon
      cannot :manage, PremiumPlan
      can :approvecount, :friendship
    elsif user.role? :plus
      can :manage, :all
      cannot :download, Route
      cannot :index, User
      cannot :promote, User
      cannot :manage, Coupon
      cannot :manage, PremiumPlan
    elsif user.role? :pro
      can :manage, :all
      cannot :index, User
      cannot :promote, User
      cannot :manage, Coupon
      cannot :manage, PremiumPlan

      cannot :upgrade, :profile
    elsif  user.role? :admin
      can :manage, :all

      cannot :upgrade, :profile
    end

    cannot :view_details, User
    can    :view_details, User, id: user.friends_ids

    cannot [:unfriend], User
    cannot :befriend, User, id: user.friends_ids
    can    :unfriend, User, id: user.friends_ids

    cannot [:leave], Club
    can    :join,  Club   # TODO privateness etc.
    cannot :join,  Club, id: user.clubs_ids
    can    :leave, Club, id: user.clubs_ids
  end


  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details:
  # https://github.com/ryanb/cancan/wiki/Defining-Abilities
end
