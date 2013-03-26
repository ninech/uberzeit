class LdapSync
  class Users
    extend LdapSync::Common

    class << self

      def sync
        sync_all_users
      end

      private

      def sync_all_users
        Person.find_all.each { |person| sync_user(person) }
      end

      def sync_user(person)
        user = User.find_by_uid(person.id)

        if person.cancelled?
          user.destroy unless user.nil?
        else
          if user.nil?
            user = User.create(uid: person.id, time_zone: Time.zone.name)
          end

          sync_user_attributes(user, person)
        end
      end

      def sync_user_attributes(user, person)
        if user.name != person.displayname
          user.name = person.displayname
          user.save!
        end
      end

    end
  end
end
