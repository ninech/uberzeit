class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can [:read, :update], User, id: user.id
      can :read, Employment, user_id: user.id

      can :read, TimeType
      can :manage, TimeSheet, user_id: user.id

      can :manage, TimeEntry, time_sheet: { user_id: user.id }

      can [:read, :create], Activity, user_id: user.id
      can [:update, :destroy], Activity, user_id: user.id, locked: false

      can :read, Absence, time_sheet: { user_id: user.id }
      can :read, Adjustment, time_sheet: { user_id: user.id }
      can :read, Project
      can :read, ActivityType

      if user.team_leader?
        can :read, Team, id: manageable_team_ids(user)
        can :read, User, id: manageable_user_ids(user)

        can :manage, TimeSheet, user_id: manageable_user_ids(user)
        can :manage, TimeEntry, time_sheet: { user_id: manageable_user_ids(user) }
        can :manage, Absence, time_sheet: { user_id: manageable_user_ids(user) }

        can [:read, :create], Activity, user_id: manageable_user_ids(user)
        can [:update, :destroy, :lock], Activity, user_id: manageable_user_ids(user), locked: false

        can :manage, :billability
        can :manage, :vacation # summary
        can :manage, :work # summary
      end

      if user.accountant?
        can :manage, :billing
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
