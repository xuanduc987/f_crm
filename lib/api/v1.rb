class API::V1 < Grape::API
  version "v1", using: :path
  mount GoogleCalendarAPI
end