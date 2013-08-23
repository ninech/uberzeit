API::Shared::Validators::Includes

class API::User::Resources::Absences < Grape::API
  helpers do
    include AbsencesHelper
  end

  resource :absences do

    desc 'Lists all of your absences'
    params do
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get do
      sheet = current_user.current_time_sheet
      present sheet.absences, with: API::Shared::Entities::Absence, embed: params[:embed]
    end

    desc 'Lists all of your absences on a given date'
    params do
      requires :date, type: Date
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get 'date/:date', requirements: { date: /(\d{4})\D?(0[1-9]|1[0-2])\D?([12]\d|0[1-9]|3[01])/ } do
      absences = FindDailyAbsences.new(current_user.time_sheets, params[:date])
                                  .result
                                  .values
                                  .flatten
      present absences, with: API::Shared::Entities::Absence, embed: params[:embed]
    end

    namespace :team do

      desc 'Lists all the absences of your teams on a given date' do
      end
      params do
        requires :date, type: Date
        optional :embed, type: Array, includes: %w[user time_type]
      end
      get 'date/:date' do
        team_time_sheets = team_time_sheets_by_user(current_user)
        absences = FindDailyAbsences.new(team_time_sheets, params[:date])
                                    .result
                                    .values
                                    .flatten
        present absences, with: API::Shared::Entities::Absence, embed: params[:embed]
      end

    end

  end
end
