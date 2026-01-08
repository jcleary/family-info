class Restaurants
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def open_today
    @open = []
    today = Date.today
    dow_words = today.strftime("%A").downcase

    config.restaurants.each do |restaurant|
      opening_hours = Array(restaurant[:opening_hours][dow_words])
      unless opening_hours.include?("Closed")
        @open << { name: restaurant[:name], opening_hours: opening_hours }
      end
    end

    @open
  end
end