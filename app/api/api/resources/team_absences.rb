class API::Resources::TeamAbsences < Grape::API
  resource :team_absences do

    desc 'Lists all the absences of your teams on a given date' do
    end
    params do
      requires :date, type: Date
      optional :embed, type: Array, includes: %w[user time_type]
    end
    get ':date' do
      absences = FindAbsences.new(current_user, params[:date])
                             .team_absences
                             .values
                             .flatten
      present absences, with: API::Entities::Absence, embed: params[:embed]
    end

  end
end
