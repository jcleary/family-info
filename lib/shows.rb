class Shows

  SOON_DAYS = 4
  DAYS_AHEAD = 21

  def initialize(config)
    @config = config
  end

  def upcoming_shows(days_ahead = DAYS_AHEAD)
    @events = []
    @config.venues.each do |venue|
      venue[:events].each do |event|
        if event[:start_date]
          if event[:end_date] > Date.today && event[:start_date] < (Date.today + days_ahead)

            @events << {
              venue: venue[:name],
              name: event[:name],
              start_date: event[:start_date],
              end_date: event[:end_date],
              starts_on: Date.today >= event[:start_date] ? " Today" : "#{(event[:start_date] - Date.today).to_i} days",
              dates: event[:start_date] == event[:end_date] ? event[:start_date].strftime('%e %b') : "#{event[:start_date].strftime('%e')} - #{event[:end_date].strftime('%e %b')}",
              soon?: event[:start_date] < (Date.today + SOON_DAYS)
            }
          end
        end
      end
    end

    @events.sort! { |x, b| x[:start_date] <=> b[:start_date] }

    @events
  end
end