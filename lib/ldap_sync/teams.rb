class LdapSync
  class Teams
    extend LdapSync::Common

    class << self

      def sync
        sync_all_teams
      end

      private

      def sync_all_teams
        Department.find_all.each { |department| sync_team(department) }
      end


      def sync_team(department)
        unless team = Team.find_by_uid(department.id)
          team = Team.create(uid: department.id)
        end

        sync_team_attributes(team, department)
      end

      def sync_team_attributes(team, department)
        if team.name != department.cn
          team.name = department.cn
          team.save!
        end
      end

    end
  end
end
