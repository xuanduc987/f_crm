Rails.application.routes.draw do
  get "/auth" => "oauths#auth"
  get "/oauth2callback" => "oauths#callback"
end
