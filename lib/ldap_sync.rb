# Class for synchronizing Nine LDAP data into the UZ DB
class LdapSync
  class << self
    def sync_person(id)
      # Users
      person = Person.find_by_mail(id)
      user = sync_user(person)

      # Make sure team exists
      sync_teams(user, person)

      # Check associations between user and various teams
      sync_associations(user)

      user
    end

    private

    def sync_user(person)
      unless User.find_by_uid(person.id)
        User.create(uid: person.id, time_zone: Time.zone.name)
      end

      user = User.find_by_uid(person.id)
      sync_user_attributes(user, person)
      user
    end

    def sync_user_attributes(user, person)
      if user.name != person.displayname
        user.name = person.displayname
        user.save!
      end
    end

    def sync_team(department)
      unless Team.find_by_ldap_id(department.id)
        Team.create(ldap_id: department.id)
      end

      team = Team.find_by_ldap_id(department.id)
      sync_team_attributes(team, department)
      team
    end

    def sync_team_attributes(team, department)
      if team.name != department.cn
        team.name = department.cn
        team.save!
      end
    end

    def sync_teams(user, person)
      person.departments.each { |department| sync_team(department) }

      Department.find_all.each do |department|
        # search for leaderships (person.departments only holds memberships)
        if department.managers.include?(person)
          department = Department.find(department.id)
          sync_team(department)
        end
      end
    end

    def sync_associations(user)
      Team.all.each do |team|
        sync_team_leader_associations(team, user)
        sync_team_member_associations(team, user)
      end
    end

    def sync_team_leader_associations(team, user)
      if team.has_leader?(user) && has_leader?(user.uid, team.ldap_id)
        # leader exists in both -> do nothing
      elsif has_leader?(user.uid, team.ldap_id)
        # leader exists only in LDAP -> Sync
        team.leaders << user
        team.save!
      elsif team.has_leader?(user)
        # leader exists only in DB -> drop
        team.leaders.delete(user)
        team.save!
      end
    end

    def sync_team_member_associations(team, user)
      if team.has_member?(user) && has_member?(user.uid, team.ldap_id)
        # member exists in both -> do nothing
      elsif has_member?(user.uid, team.ldap_id)
        # member exists only in LDAP -> Sync
        team.members << user
        team.save!
      elsif team.has_member?(user)
        # member exists only in DB -> drop
        team.members.delete(user)
        team.save!
      end
    end

    def has_leader?(person_id, department_id)
      person = Person.find(person_id)
      department = Department.find(department_id)

      department.managers.include?(person)
    end

    def has_member?(person_id, department_id)
      person = Person.find(person_id)
      department = Department.find(department_id)

      department.people.include?(person)
    end
  end
end
