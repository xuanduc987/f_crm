class API < Grape::API
  format :json
  default_error_formatter :json

  rescue_from Google::Apis::AuthorizationError
  error_formatter :json, ->(message, backtrace, options, env) {
    { error: "Authentication error!" }
  }

  namespace :bookings do
    desc "Get bookings with filter"
    params do
      requires :auth_token, type: Hash, desc: "Google Oauth2 token"
      optional :time_min, type: Time, desc: "Lower bound time to filter"
      optional :time_max, type: Time, desc: "Upper bound time to filter"
      optional :team, type: String, desc: "Team name"
      optional :room, type: String, desc: "Room name"
      optional :start_time, type: Time, desc: "Start time"
      optional :end_time, type: Time, desc: "End time"
      optional :recurrence, type: Array, desc: "Recurrence rules"
    end
    get "/" do
      BookingService.new(params[:auth_token])
        .filter(**params.to_hash.symbolize_keys.except(:auth_token))
    end

    desc "Book a room"
    params do
      requires :auth_token, type: Hash, desc: "Google Oauth2 token"
      requires :team, type: String, desc: "Team name"
      requires :room, type: String, desc: "Room name"
      requires :start_time, type: Time, desc: "Start time"
      requires :end_time, type: Time, desc: "End time"
      optional :description, type: String, desc: "Description"
      optional :recurrence, type: Array, desc: "Recurrence rules"
    end
    post "/" do
      BookingService.new(params[:auth_token])
        .book(**params.to_hash.symbolize_keys.except(:auth_token))
    end
  end
end
