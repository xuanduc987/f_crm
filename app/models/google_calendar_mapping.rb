class GoogleCalendarMapping
  require "google/apis/calendar_v3"
  Calendar = Google::Apis::CalendarV3

  TIME_ZONE = "Asia/Saigon"

  class << self
    def booking_items_from_event event
      booking_item = BookingItem.new.tap do |booking|
        summary = event.summary || ""
        index  = summary.index('-')
        if index.present?
          booking.room = summary.slice(0..(index - 1)).strip
          booking.team = summary.slice((index + 1)..-1).strip
          booking.id = event.id
          booking.description = event.description
          booking.start_time = Time.parse event.start.date_time.to_s
          booking.end_time = Time.parse event.end.date_time.to_s
          booking.recurrence = event.recurrence
        end
      end
      booking_item.id.nil? ? nil : booking_item
    end

    def event_from_booking_item booking
      Calendar::Event.new(
        summary: "#{booking.room} - #{booking.team}",
        start: Calendar::EventDateTime.new(
          date_time: DateTime.parse(booking.start_time.to_s),
          time_zone: TIME_ZONE
        ),
        end: Calendar::EventDateTime.new(
          date_time: DateTime.parse(booking.end_time.to_s),
          time_zone: TIME_ZONE
        ),
        description: booking.description,
        recurrence: booking.recurrence
      )
    end
  end
end
