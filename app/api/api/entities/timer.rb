class API::Entities::Timer < Grape::Entity
  expose :time_type_id
  expose :start_date, as: :date
  expose :start_time, as: :start
  expose :end_time, as: :end
end
