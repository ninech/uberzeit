class API::Shared::Validators::Includes < Grape::Validations::SingleOptionValidator
  def validate_param!(attr_name, params)
    if (params[attr_name] - @option).any?
      raise Grape::Exceptions::Validation, status: 422, param: attr_name, message_key: :invalid
    end
  end
end
