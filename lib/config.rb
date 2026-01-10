class Config
  attr_reader :collection_day_of_week, :bins

  def initialize()
    @collection_day_of_week = raw_config.fetch("collection_day_of_week").to_i
  end

  def bins
    @bins ||= raw_config.fetch("bins").map do |b|
      {
        color: b.fetch("color"),
        start_date: Date.parse(b.fetch("start_date")),
        cycle_weeks: b.fetch("cycle_weeks").to_i
      }
    end
  end

  def venues
    @venues ||=
      raw_config.fetch("venues").map do |v|
        events = v.fetch("events").map do |e|
          {
            name: e.fetch("name"),
            playwright: e.fetch("playwright", ''),
            start_date: Date.parse(e.fetch("start_date")),
            end_date: Date.parse(e.fetch("end_date"))
          }
        end
        {
          name: v.fetch("name"),
          url: v.fetch("url", ""),
          events: events
        }
      end
  end

  def weather
    @weather ||=
      begin
        raw = raw_config.fetch("weather")
        {
          latitude: raw.fetch("latitude"),
          longitude: raw.fetch("longitude"),
          timezone: raw.fetch("timezone"),
          location_name: raw.fetch("location_name"),
        }
      end
  end

  def restaurants
    @restaurants ||=
      raw_config.fetch("restaurants").map do |r|
        {
          name: r.fetch("name"),
          opening_hours: r.fetch("opening_hours")
        }
      end
  end

  def calendar
    @calendar ||=
      begin
        raw = raw_config.fetch("calendar")
        {
          green_weeks: raw.fetch("green_weeks").collect { |d| Date.parse(d) },
          yellow_weeks: raw.fetch("yellow_weeks").collect { |d| Date.parse(d) },
        }
      end
  end

  private

  def raw_config
    @raw_config ||=
      Dir.glob("config/*.yml").inject({}) do |raw, file|
        raw.merge(YAML.load_file(file))
      end
  end
end