class TimeTypeForTimer < Grape::Validations::Validator
  def validate_param!(attr_name, params)
    time_type = TimeType.find(params[attr_name])
    unless time_type.is_work?
      raise Grape::Exceptions::Validation, status: 400, param: @scope.full_name(attr_name), message_key: :time_type_for_timer
    end
  end
end
