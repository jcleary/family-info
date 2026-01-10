class Config
  attr_reader :collection_day_of_week, :bins
  attr_reader :restaurants
  attr_reader :weather

  def initialize(path = 'config')
    @path = path
    @raw = YAML.load_file("#{path}/config.yml") # => Hash

    @collection_day_of_week = @raw.fetch("collection_day_of_week").to_i

    @bins = @raw.fetch("bins").map do |b|
      {
        color: b.fetch("color"),
        start_date: Date.parse(b.fetch("start_date")),
        cycle_weeks: b.fetch("cycle_weeks").to_i
      }
    end

    @restaurants = @raw.fetch("restaurants").map do |r|
      {
        name: r.fetch("name"),
        opening_hours: r.fetch("opening_hours")
      }
    end
    grab_weather
  end

  def venues
    @venues ||=
      begin
        raw = YAML.load_file("#{@path}/venues.yml")
        raw.fetch("venues").map do |v|
          events = v.fetch("events").map do |e|
            {
              name: e.fetch("name"),
              playwright: e.fetch("playwright"),
              start_date: Date.parse(e.fetch("start_date")),
              end_date: Date.parse(e.fetch("end_date"))
            }
          end
          {
            name: v.fetch("name"),
            url: v.fetch("url"),
            events: events
          }
        end
      end
  end

  private

  def grab_weather
    w = @raw.fetch("weather")
    @weather = {
      latitude: w.fetch("latitude"),
      longitude: w.fetch("longitude"),
      timezone: w.fetch("timezone"),
      location_name: w.fetch("location_name"),
    }
  end

  def load_config(file)
    YAML.load_file(file)
  end
end