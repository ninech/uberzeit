class Ability
  include CanCan::Ability

  def initialize(user)

    if user
      can [:read, :update], User, id: user.id
      can :read, Employment, user_id: user.id

      can :read, TimeType
      can :manage, TimeSheet, user_id: user.id

      can :manage, TimeEntry, time_sheet: { user_id: user.id }
      can :manage, Absence, time_sheet: { user_id: user.id }
      can :manage, Timer, time_sheet: { user_id: user.id }

      can :read, Team, id: Team.with_role(:team_leader, user).map(&:id)

      if user.has_role?(:admin)
        can :manage, TimeType
        can :manage, TimeSheet
        can :manage, TimeEntry
        can :manage, Absence
        can :manage, Employment
        can :manage, PublicHoliday
        can :manage, User
        can :manage, Team
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
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
end
