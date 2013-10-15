class API::Shared::Entities::Absence < Grape::Entity
  expose :id

  expose :start_date
  expose :end_date
  expose :recurring?, as: :is_recurring
  expose :weekly_repeat_interval, if: ->(absence, options) { absence.recurring? }
  expose :daypart

  expose :time_type, using: API::User::Entities::TimeType, if: ->(*args) { embed_time_type?(*args) }
  expose :time_type_id, unless: ->(*args) { embed_time_type?(*args) }

  expose :user, using: API::User::Entities::User, if: ->(*args) { embed_user?(*args) }
  expose :user_id, unless: ->(*args) { embed_user?(*args) }

  def self.embed_time_type?(absence, options)
    options[:embed] && options[:embed].include?('time_type')
  end

  def self.embed_user?(absence, options)
    options[:embed] && options[:embed].include?('user')
  end
end
