class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :read, TimeType

      can [:read, :update], User, id: user.id
      can :read, Employment, user_id: user.id

      can :manage, TimeEntry, user_id: user.id
      can :read, Absence, user_id: user.id
      can :read, Adjustment, user_id: user.id

      if activities_enabled?
        can :read, Activity
        can [:create, :update, :destroy], Activity, user_id: user.id
        cannot [:update, :destroy], Activity, user_id: user.id, reviewed: true
        can :read, Project
        can :read, ActivityType
      end

      if user.team_leader?

        can :read, Team, id: manageable_team_ids(user)
        can :read, User, id: manageable_user_ids(user)

        can :manage, TimeEntry, user_id: manageable_user_ids(user)
        can :manage, Absence, user_id: manageable_user_ids(user)

        can :manage, :vacation # summary
        can :manage, :work # summary

        if activities_enabled?
          can :manage, :billability
          can [:create, :update, :destroy, :review], Activity, user_id: manageable_user_ids(user)
          cannot [:update, :destroy], Activity, user_id: manageable_user_ids(user), reviewed: true
          can :manage, Project
        end
      end

      if user.accountant? && activities_enabled?
        can :manage, :billability
        can :manage, :billing

        can :read, User
        can [:update, :review], Activity
      end

      if user.admin?
        can :manage, :all

        unless activities_enabled?
          cannot :manage, ActivityType
          cannot :manage, Activity
          cannot :manage, Customer
          cannot :manage, Project
          cannot :manage, :billing
          cannot :manage, :billability
        end
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

  def activities_enabled?
    !UberZeit.config.disable_activities
  end
end
