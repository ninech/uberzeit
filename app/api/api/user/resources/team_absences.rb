API::Shared::Validators::Includes

class API::User::Resources::TeamAbsences < Grape::API
  helpers do
    include AbsencesHelper
  end

  resource :team_absences do

    desc 'Lists all the absences of your teams on a given date' do
    end
    params do
      requires :date, type: Date
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get ':date' do
      team_time_sheets = time_sheets_from_team(current_user)
      absences = FindDailyAbsences.new(team_time_sheets, params[:date])
                                  .result
                                  .values
                                  .flatten
      present absences, with: API::User::Entities::Absence, embed: params[:embed]
    end

  end
end
