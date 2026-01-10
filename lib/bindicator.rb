require "yaml"
require "date"

class Bindicator
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def next_bin_day
    @next_bin_day ||=
      begin
        next_bin_day = Date.today
        next_bin_day += 1 until next_bin_day.wday == config.collection_day_of_week
        next_bin_day
      end
  end

  def next_bin_day_words
    if next_bin_day == Date.today
      "Today"
    elsif next_bin_day == Date.today + 1
      "Tomorrow"
    else
      next_bin_day.strftime("%a, %b %-d")
    end
  end

  def bins_for_next_collection
    config.bins.select do |b|
      delta_days = (next_bin_day - b[:start_date]).to_i
      delta_weeks = delta_days / 7
      delta_weeks % b[:cycle_weeks] == 0
    end.collect { |b| b[:color] }
  end
end