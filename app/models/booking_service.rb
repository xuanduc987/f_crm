class BookingService
  include IceCube

  def initialize(credentials)
    @calendar = GoogleCalendarConnection.new(credentials)
  end

  def book(team:, room:, start_time:, end_time:, description: nil, recurrence: [])
    booking = BookingItem.new
    booking.team = team
    booking.room = room
    booking.description = description
    booking.start_time = start_time
    booking.end_time = end_time
    booking.recurrence = recurrence

    event = GoogleCalendarMapping.event_from_booking_item booking

    @calendar.insert_event event
  end

  def filter(time_min: Time.now, time_max: 3.month.from_now,
             team: nil, room: nil, start_time: nil, end_time: nil, recurrence: [])

    events = @calendar.get_events(time_min, time_max)

    bookings = events.map { |x| GoogleCalendarMapping.booking_items_from_event(x) }
    bookings.reject(&:blank?)

    if team.present?
      bookings.select! { |booking| booking.team == team }
    end

    if room.present?
      bookings.select! { |booking| booking.room == room }
    end

    if recurrence.present?
      schedule = Schedule.new(start_time, end_time: end_time)
      recurrence.each do |r|
        schedule.add_recurrence_rule Rule.from_ical(r)
      end

      bookings.select! do |booking|
        schedule.occurring_between? booking.start_time, booking.end_time
      end
    end

    bookings
  end
end
