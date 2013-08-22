class API::User::Entities::Timer < Grape::Entity
  format_with :duration_in_hhmm do |duration|
    UberZeit.duration_in_hhmm(duration)
  end

  expose :time_type_id
  expose :start_date, as: :date
  expose :start_time, as: :start
  expose :end_time, as: :end
  expose :duration, format_with: :duration_in_hhmm
end
