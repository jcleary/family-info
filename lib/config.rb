class Config
  attr_reader :collection_day_of_week, :bins, :venues
  attr_reader :restaurants

  def initialize(file_path)
    raw = YAML.load_file(file_path) # => Hash

    @collection_day_of_week = raw.fetch("collection_day_of_week").to_i

    @bins = raw.fetch("bins").map do |b|
      {
        color: b.fetch("color"),
        start_date: Date.parse(b.fetch("start_date")),
        cycle_weeks: b.fetch("cycle_weeks").to_i
      }
    end

    @restaurants = raw.fetch("restaurants").map do |r|
      {
        name: r.fetch("name"),
        opening_hours: r.fetch("opening_hours")
      }
    end
  end
end