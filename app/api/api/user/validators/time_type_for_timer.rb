class API::User::Validators::TimeTypeForTimer < Grape::Validations::Validator
  def validate_param!(attr_name, params)
    time_type = params[attr_name].blank? ? nil : TimeType.find(params[attr_name])
    if time_type.nil? || !time_type.is_work?
      raise Grape::Exceptions::Validation, status: 422, param: @scope.full_name(attr_name), message_key: :time_type_for_timer
    end
  end
end
