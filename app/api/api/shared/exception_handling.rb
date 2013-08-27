module API::Shared::ExceptionHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Grape::Exceptions::ValidationErrors do |e|
     Rack::Response.new({
        'status' => e.status,
        'message' => e.message,
        'errors' => e.errors
      }.to_json, 422)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      Rack::Response.new({
        'status' => 422,
        'message' => e.record.errors.full_messages.to_sentence,
        'errors' => e.record.errors
      }.to_json, 422)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      Rack::Response.new({
        'status' => 404
      }.to_json, 404)
    end
  end

end
