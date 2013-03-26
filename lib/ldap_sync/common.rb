class LdapSync
  module Common

    def each_user_in_person_list(person_list)
      person_list.each do |person|
        next if person.cancelled?
        user = User.find_by_uid(person.id)
        yield(user) if user
      end
    end

  end
end
