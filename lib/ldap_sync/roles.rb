class LdapSync
  class Roles
    extend LdapSync::Common

    class << self

      NINE_UBERZEIT_ADMIN_DEPARTMENTS = %w(Management Administration)
      if Rails.env.development?
        NINE_UBERZEIT_ADMIN_DEPARTMENTS << 'Development'
      end

      def sync
        sync_all_roles
      end

      private

      def sync_all_roles
        drop_revoked_roles
        ensure_roles
      end

      def drop_revoked_roles
        # Admin
        User.with_role(:admin).each do |user|
          user.remove_role(:admin) unless admin_in_ldap?(user)
        end

        # Team Leaders
        Team.all.each do |team|
          department = Department.find(team.uid)

          team.members.each do |member|
            person = Person.find_by_mail(member.uid)

            if member.has_role?(:team_leader, team) && !department.managers.include?(person)
              member.remove_role(:team_leader, team)
            end
          end
        end
      end

      def ensure_roles
        Department.find_all.each do |department|
          if NINE_UBERZEIT_ADMIN_DEPARTMENTS.include?(department.cn)
            each_user_in_person_list(department.people) { |user| user.add_role(:admin) }
            each_user_in_person_list(department.managers) { |user| user.add_role(:admin) }
          end

          each_user_in_person_list(department.managers) do |user|
            team = Team.find_by_uid(department.id)
            raise "Team not found for department #{department}" unless team
            user.add_role(:team_leader, team)
          end
        end
      end

      def admin_in_ldap?(user)
        person = Person.find_by_mail(user.uid)
        person.departments.any? { |department| NINE_UBERZEIT_ADMIN_DEPARTMENTS.include?(department.cn) }
      end
    end
  end
end


