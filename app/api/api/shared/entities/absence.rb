class API::Shared::Entities::Absence < Grape::Entity
  expose :id

  expose :start_date
  expose :end_date

  expose :is_recurring
  expose :weekly_repeat_interval, if: ->(object, options) { object.is_recurring }
  expose :first_start_date, if: ->(object, options) { object.is_recurring }
  expose :first_end_date, if: ->(object, options) { object.is_recurring }

  expose :daypart

  expose :time_type, using: API::User::Entities::TimeType, if: ->(*args) { embed_time_type?(*args) }
  expose :time_type_id, unless: ->(*args) { embed_time_type?(*args) }

  expose :user, using: API::User::Entities::User, if: ->(*args) { embed_user?(*args) }
  expose :user_id, unless: ->(*args) { embed_user?(*args) }

  def self.embed_time_type?(object, options)
    options[:embed] && options[:embed].include?('time_type')
  end

  def self.embed_user?(object, options)
    options[:embed] && options[:embed].include?('user')
  end
end
