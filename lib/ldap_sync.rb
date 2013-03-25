# Class for synchronizing Nine LDAP data into the UZ DB
class LdapSync
  class << self

    def all
      sync_all_users
      sync_all_teams
      sync_all_links
    end

    private

    def sync_all_users
      @persons = Person.find_all.each { |person| sync_user(person) }
    end

    def sync_all_teams
      @departments = Department.find_all.each { |department| sync_team(department) }
    end

    def sync_all_links
      drop_deleted_links
      add_new_links
    end

    def drop_deleted_links
      Team.all.each do |team|
        # delete_if does not work on ActiveRecord::Collections, oh noes!
        leaders_to_remove = team.leaders.select { |leader| not leader_in_ldap?(team.uid, leader.uid) }
        team.leaders.delete(leaders_to_remove)

        members_to_remove =  team.members.select { |member| not member_in_ldap?(team.uid, member.uid) }
        team.members.delete(members_to_remove)
      end
    end

    def add_new_links
      @departments.each do |department|
        team = Team.find_by_uid(department.id)

        department.people.each do |person|
          user = User.find_by_uid(person.id)
          unless team.has_member?(user)
            team.members.push(user)
          end
        end

        department.managers.each do |manager|
          user = User.find_by_uid(manager.id)
          unless team.has_leader?(user)
            team.leaders.push(user)
          end
        end
      end
    end

    def sync_user(person)
      unless user = User.find_by_uid(person.id)
        user = User.create(uid: person.id, time_zone: Time.zone.name)
      end

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
      unless team = Team.find_by_uid(department.id)
        team = Team.create(uid: department.id)
      end

      sync_team_attributes(team, department)
      team
    end

    def sync_team_attributes(team, department)
      if team.name != department.cn
        team.name = department.cn
        team.save!
      end
    end

    def leader_in_ldap?(department_id, person_id)
      department = @departments.find { |dep| dep.id == department_id }
      department.managers.any?{ |manager| manager.uid == person_id }
    end

    def member_in_ldap?(department_id, person_id)
      department = @departments.find { |dep| dep.id == department_id }
      department.people.any?{ |member| member.uid == person_id }
    end
  end
end
