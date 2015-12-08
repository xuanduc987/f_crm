class API < Grape::API
  format :json
  helpers do
    def render_api_error!(message, status)
      error!({message: message}, status)
    end
  end
  mount API::V1
end