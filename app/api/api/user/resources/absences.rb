API::Shared::Validators::Includes

class API::User::Resources::Absences < Grape::API
  resource :absences do

    desc 'Lists all of your absences' do
    end
    params do
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get do
      sheet = current_user.current_time_sheet
      present sheet.absences, with: API::User::Entities::Absence, embed: params[:embed]
    end

    desc 'Lists all of your absences on a given date' do
    end
    params do
      requires :date, type: Date
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get ':date' do
      absences = FindDailyAbsences.new(current_user.time_sheets, params[:date])
                                  .result
                                  .values
                                  .flatten
      present absences, with: API::User::Entities::Absence, embed: params[:embed]
    end

  end
end
