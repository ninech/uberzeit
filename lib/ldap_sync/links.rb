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
          members_to_remove =  team.members.select { |member| not member_in_ldap?(team.uid, member.email) }
          team.members.delete(members_to_remove)
        end
      end

      def add_new_links
        Department.find_all.each do |department|
          team = Team.find_by_uid(department.id)

          each_user_in_person_list(department.people) do |user|
            team.members.push(user) unless team.has_member?(user)
          end
        end
      end

      def member_in_ldap?(department_id, person_id)
        department = Department.find(department_id)
        department.managers.any?{ |manager| manager.mail == person_id } || department.people.any?{ |member| member.mail == person_id }
      end
    end
  end
end
