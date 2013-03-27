class LdapSync
  class Roles
    extend LdapSync::Common

    class << self

      NINE_UBERZEIT_ADMIN_DEPARTMENTS = %w(Management Administration Development)

      def sync
        sync_all_roles
      end

      private

      def sync_all_roles
        drop_revoked_roles
        add_new_roles
      end

      def drop_revoked_roles
        User.with_role(:admin).each do |user|
          unless admin_in_ldap?(user)
            user.remove_role(:admin)
          end
        end
      end

      def add_new_roles
        Department.find_all.each do |department|
          each_user_in_person_list(department.people) do |user|
            if admin_in_ldap?(user) && !user.has_role?(:admin)
              user.add_role(:admin)
            end
          end

          each_user_in_person_list(department.managers) do |user|
            if admin_in_ldap?(user) && !user.has_role?(:admin)
              user.add_role(:admin)
            end
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


