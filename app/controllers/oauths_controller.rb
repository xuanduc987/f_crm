class OauthsController < ApplicationController
  require 'google/api_client/client_secrets'

  def auth
    redirect_to oauth2callback_path and return if session[:token].blank?
    render json: session[:token]
  end

  def callback
    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => 'https://www.googleapis.com/auth/calendar',
      :redirect_uri => oauth2callback_url)

    redirect_to auth_client.authorization_uri.to_s and return if params[:code].blank?

    auth_client.code = params[:code]
    token = auth_client.fetch_access_token
    session[:token] = token

    redirect_to auth_path
  end
end
