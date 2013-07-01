class API::Entities::Timer < Grape::Entity
  format_with :duration_in_hhmm do |duration|
    UberZeit.duration_in_hhmm(duration)
  end

  expose :time_type_id
  expose :start_date, as: :date
  expose :start_time, as: :start
  expose :end_time, as: :end
  expose :duration do |timer|
    if timer.ends.nil?
      nil
    else
      UberZeit.duration_in_hhmm(timer.duration)
    end
  end
end
