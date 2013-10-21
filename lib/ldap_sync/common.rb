class LdapSync
  module Common

    def each_user_in_person_list(person_list)
      person_list.each do |person|
        user = User.find_by_email(person.mail)
        next if not user or person.cancelled?
        yield(user)
      end
    end

  end
end
