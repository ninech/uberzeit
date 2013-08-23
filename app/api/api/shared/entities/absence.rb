# This class can be represented either by a time chunk or an absence
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

  alias_method :orig_object, :object
  def object
    @wrapped_object ||= wrap_object(orig_object)
  end

  def wrap_object(obj)
    # obj is either Absence or TimeChunk (whose parent points to the absence)
    OpenStruct.new({
      id: obj.id,
      start_date: obj.starts.to_date,
      end_date: obj.ends.to_date,
      is_recurring: obj.recurring?,
      weekly_repeat_interval: obj.recurring_schedule.weekly_repeat_interval,
      first_start_date: obj.respond_to?(:parent) ? obj.parent.start_date : obj.start_date,
      first_end_date: obj.respond_to?(:parent) ? obj.parent.end_date : obj.end_date,
      time_type: obj.time_type,
      time_type_id: obj.time_type.id,
      user: obj.user,
      user_id: obj.user.id,
      daypart: obj.daypart
    })
  end
end
