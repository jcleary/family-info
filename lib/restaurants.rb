class Restaurants
  attr_reader :config, :open, :closed

  def initialize(config)
    @config = config
    @open = []
    @closed = []

    today = Date.today
    dow_words = today.strftime("%a").downcase

    config.restaurants.each do |restaurant|
      closed_today = Array(restaurant[:closed]).include?(dow_words)
      if closed_today
        @closed << restaurant[:name]
      else
        @open << restaurant[:name]
      end
    end
  end
end