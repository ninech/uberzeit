class LdapSync
  class Links
    extend LdapSync::Common

    class << self

      def sync
        sync_all_links
      end

      private

      def sync_all_links
        drop_deleted_links
        add_new_links
      end

      def drop_deleted_links
        Team.all.each do |team|
          # delete_if does not work on ActiveRecord::Collections
          leaders_to_remove = team.leaders.select { |leader| not leader_in_ldap?(team.uid, leader.uid) }
          team.leaders.delete(leaders_to_remove)

          members_to_remove =  team.members.select { |member| not member_in_ldap?(team.uid, member.uid) }
          team.members.delete(members_to_remove)
        end
      end

      def add_new_links
        Department.find_all.each do |department|
          team = Team.find_by_uid(department.id)

          each_user_in_person_list(department.people) do |user|
            unless team.has_member?(user)
              team.members.push(user)
            end
          end

          each_user_in_person_list(department.managers) do |user|
            unless team.has_leader?(user)
              team.leaders.push(user)
            end
          end
        end
      end

      def leader_in_ldap?(department_id, person_id)
        department = Department.find(department_id)
        department.managers.any?{ |manager| manager.mail == person_id }
      end

      def member_in_ldap?(department_id, person_id)
        department = Department.find(department_id)
        department.people.any?{ |member| member.mail == person_id }
      end

    end
  end
end
