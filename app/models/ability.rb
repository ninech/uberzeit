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

      if user.team_leader?
        can :read, Team, id: manageable_team_ids(user)
        can :read, User, id: manageable_user_ids(user)

        can :manage, TimeSheet, user_id: manageable_user_ids(user)
        can :manage, TimeEntry, time_sheet: { user_id: manageable_user_ids(user) }
        can :manage, Absence, time_sheet: { user_id: manageable_user_ids(user) }
        can :manage, Timer, time_sheet: { user_id: manageable_user_ids(user) }
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
