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
      present current_user.absences, with: API::Shared::Entities::Absence, embed: params[:embed]
    end

    desc 'Lists all of your absences on a given date'
    params do
      requires :date, type: Date
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get 'date/:date', requirements: { date: /(\d{4})\D?(0[1-9]|1[0-2])\D?([12]\d|0[1-9]|3[01])/ } do
      absences = FindDailyAbsences.new(current_user, params[:date]).result
      present absences, with: API::Shared::Entities::Absence, embed: params[:embed]
    end
  end

  namespace :team_absences do
    desc 'Lists all the absences of your teams on a given date' do
    end
    params do
      requires :date, type: Date
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get 'date/:date' do
      users = other_team_members(current_user)
      absences = FindDailyAbsences.new(users, params[:date]).result
      present absences, with: API::Shared::Entities::Absence, embed: params[:embed]
    end

  end
end
