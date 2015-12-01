class GoogleCalendarConnection
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets'

  Calendar = Google::Apis::CalendarV3

  def initialize(credentials)
    @auth_client = Signet::OAuth2::Client.new(credentials)
  end

  def insert_event event, calendar_id: "primary"
    client.insert_event(
      calendar_id,
      event
    )
  end

  def get_event event_id, calendar_id: "primary"
    client.get_event(
      calendar_id,
      event_id
    )
  end

  def get_events time_min, time_max, calendar_id: "primary"
    events = []

    page_token = nil
    while true
      results = client.list_events(
          calendar_id,
          max_results: 2500,
          single_events: true,
          order_by: 'startTime',
          time_min: time_min.iso8601,
          time_max: time_max.iso8601,
          page_token: page_token
      )

      page_token = results.next_page_token
      events += results.items
      break if page_token.nil?
    end

    events
  end

  private

  def client
    @client ||= Calendar::CalendarService.new.tap do |client|
      client.authorization = @auth_client
    end
  end
end
