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
        remove_deleted_persons
      end

      def sync_user(person)
        user = User.find_by_email(person.mail)

        if person.cancelled?
          user.destroy unless user.nil?
        else
          if user.nil?
            user = User.create(email: person.mail)
          end

          sync_user_attributes(user, person)
        end
      end

      def remove_deleted_persons
        User.all.each do |user|
          person = Person.find_by_mail(user.email)
          user.destroy if person.nil?
        end
      end

      def sync_user_attributes(user, person)
        user.name = person.sn
        user.given_name = person.givenname
        user.birthday = Date.parse(person.birthdate) unless person.birthdate.nil?

        user.save!
      end

    end
  end
end
