# Class for synchronizing Nine LDAP data into the UZ DB
class LdapSync
  class << self
    def sync_person(id)
      # Users
      person = Person.find_by_mail(id)

      unless User.find_by_uid(person.id)
        User.create(uid: person.id, time_zone: Time.zone.name)
      end

      user = User.find_by_uid(person.id)

      # Synchronize name etc. IF CHANGED
      if user.name != person.displayname
        user.name = person.displayname
        user.save!
      end

      # Make sure team exists
      person.departments.each { |department| sync_department(department.id) }
      Department.find_all.each do |department|
        # search for leaderships (person.departments only holds memberships)
        if department.managers.include?(person)
          sync_department(department.id)
        end
      end

      # Check associations between user and various teams
      Team.all.each do |team|
        # 3 cases
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

      user
    end

    def sync_department(id)
      department = Department.find(id)

      unless Team.find_by_ldap_id(department.id)
        Team.create(ldap_id: department.id)
      end

      team = Team.find_by_ldap_id(department.id)

      # Synchronize name etc. IF CHANGED
      if team.name != department.cn
        team.name = department.cn
        team.save!
      end

      team
    end

    private

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
