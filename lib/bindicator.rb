require "yaml"
require "date"

class Bindicator

  attr_reader :collection_day_of_week, :bins

  def initialize
    raw = YAML.load_file("config.yml") # => Hash

    @collection_day_of_week = raw.fetch("collection_day_of_week").to_i

    @bins = raw.fetch("bins").map do |b|
      {
        color: b.fetch("color"),
        start_date: Date.parse(b.fetch("start_date")),
        cycle_weeks: b.fetch("cycle_weeks").to_i
      }
    end
  end

  def next_bin_day
    next_bin_day = Date.today
    next_bin_day += 1 until next_bin_day.wday == collection_day_of_week
    next_bin_day
  end

  def next_bin_day_words
    if next_bin_day == Date.today
      "today"
    elsif next_bin_day == Date.today + 1
      "tomorrow"
    else
      "on #{next_bin_day.strftime("%A, %B %-d")}"
    end
  end
end