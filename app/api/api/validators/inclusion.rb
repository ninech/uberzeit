class Inclusion < Grape::Validations::SingleOptionValidator
  def validate_param!(attr_name, params)
    unless (params[attr_name] - @option).length == 0
      throw :error, status: 400, message: "#{attr_name}: must be one of #{@option.to_sentence} (Given: #{params[attr_name]})"
    end
  end
end
