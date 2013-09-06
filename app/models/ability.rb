class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :read, Project
      can :read, ActivityType
      can :read, TimeType

      can [:read, :update], User, id: user.id
      can :read, Employment, user_id: user.id

      can :manage, TimeSheet, user_id: user.id
      can :manage, TimeEntry, time_sheet: { user_id: user.id }
      can :read, Absence, time_sheet: { user_id: user.id }
      can :read, Adjustment, time_sheet: { user_id: user.id }

      can [:read, :create, :update, :destroy], Activity, user_id: user.id
      cannot [:update, :destroy], Activity, user_id: user.id, reviewed: true

      if user.team_leader?
        can :read, Team, id: manageable_team_ids(user)
        can :read, User, id: manageable_user_ids(user)

        can :manage, TimeSheet, user_id: manageable_user_ids(user)
        can :manage, TimeEntry, time_sheet: { user_id: manageable_user_ids(user) }
        can :manage, Absence, time_sheet: { user_id: manageable_user_ids(user) }

        can [:read, :create, :update, :destroy, :review], Activity, user_id: manageable_user_ids(user)
        cannot [:update, :destroy], Activity, user_id: manageable_user_ids(user), reviewed: true

        can :manage, :vacation
        can :manage, :work

        can :manage, :billability
      end

      if user.accountant?
        can :manage, :billability
        can :manage, :billing

        can :read, User
        can [:read, :update, :review], Activity
      end

      if user.admin?
        can :manage, :all
      end
    end
  end

  private

  def manageable_team_ids(user)
    @manageable_team_ids ||= Team.with_role(:team_leader, user).pluck(:id)
  end

  def manageable_user_ids(user)
    @manageable_user_ids ||= User.joins(:teams).where(teams: {id: Team.with_role(:team_leader, user)}).pluck(:id)
  end
end
