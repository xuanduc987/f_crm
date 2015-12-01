class OauthsController < ApplicationController
  require 'google/api_client/client_secrets'

  def auth
    redirect_to callback_path and return if session[:credentials].blank?
    render text: session[:credentials]
  end

  def callback
    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => 'https://www.googleapis.com/auth/calendar',
      :redirect_uri => oauth2callback_url)

    redirect_to auth_client.authorization_uri.to_s and return if params[:code].blank?

    auth_client.code = params[:code]
    auth_client.fetch_access_token!
    auth_client.client_secret = nil

    # Work around
    # session[:credentials] = auth_client.to_json
    temp = JSON.parse(auth_client.to_json)
    temp["authorization_uri"] = auth_client.authorization_uri.to_s
    temp["token_credential_uri"] = auth_client.token_credential_uri.to_s
    temp["redirect_uri"] = auth_client.redirect_uri.to_s

    session[:credentials] = temp.to_json

    redirect_to auth_path
  end
end
