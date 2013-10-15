API::Shared::Validators::Includes

class API::App::Resources::Absences < Grape::API

  helpers do
    include AbsencesHelper
  end

  resources :absences do
    desc 'Retrieves an absence'
    params do
      requires :id, type: Integer
    end
    get ':id', requirements: { id: /[0-9]*/ } do
      present Absence.find(params[:id]), with: API::Shared::Entities::Absence
    end

    namespace :team do
    desc 'Retrieves the absences for the given team on the given date'
      params do
        requires :team_id, type: Integer
        requires :date, type: Date
        optional :embed, type: Array, includes: %w[user time_type]
      end
      get ':team_id/date/:date'do
        users = Team.find(params[:team_id]).members
        absences = FindDailyAbsences.new(users, params[:date]).result
        present absences, with: API::Shared::Entities::Absence, embed: params[:embed]
      end
    end
  end

end
