class Restaurants
  attr_reader :config, :open, :closed

  def initialize(config)
    @config = config
    @open = []
    @closed = []

    today = Date.today
    dow_words = today.strftime("%A").downcase

    config.restaurants.each do |restaurant|
      opening_hours = Array(restaurant[:opening_hours][dow_words])
      if opening_hours.include?("Closed")
        @closed << { name: restaurant[:name], opening_hours: opening_hours }
      else
        @open << { name: restaurant[:name], opening_hours: opening_hours }
      end
    end
  end
end