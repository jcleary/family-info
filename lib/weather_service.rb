require "yaml"
require "json"
require "net/http"
require "uri"
require "time"
require "date"
require "zlib"
require "stringio"

class WeatherService
  def initialize(config)
    @config = config
  end

  # => { location:, date:, temp_now_c:, feels_like_now_c:, chance_of_rain_max_pct:, temp_max_c:, feels_like_max_c: }
  def today
    tz = @config.weather[:timezone] || loc.fetch("timezone")

    uri = URI("https://api.open-meteo.com/v1/forecast")
    uri.query = URI.encode_www_form(
      latitude: @config.weather[:latitude],
      longitude: @config.weather[:longitude],
      timezone: tz,
      forecast_days: 1,
      temperature_unit: "celsius",
      current: "temperature_2m,apparent_temperature",
      hourly: "temperature_2m,apparent_temperature,precipitation_probability"
    )

    data = get_json(uri)

    # “Today” starts at 00:00 today in the requested timezone. :contentReference[oaicite:3]{index=3}
    times = data.dig("hourly", "time") || []
    temps = data.dig("hourly", "temperature_2m") || []
    feels = data.dig("hourly", "apparent_temperature") || []
    probs = data.dig("hourly", "precipitation_probability") || []

    today_date = times.empty? ? Date.today : Time.parse(times.first).to_date
    idxs = times.each_index.select { |i| Time.parse(times[i]).to_date == today_date }

    {
      location: @config.weather[:location_name],
      date: today_date,
      temp_now_c: data.dig("current", "temperature_2m"),
      feels_like_now_c: data.dig("current", "apparent_temperature"),
      chance_of_rain_max_pct: idxs.map { |i| probs[i] }.compact.max, # hourly precipitation probability :contentReference[oaicite:4]{index=4}
      temp_max_c: idxs.map { |i| temps[i] }.compact.max,
      feels_like_max_c: idxs.map { |i| feels[i] }.compact.max
    }
  end

  private

  def get_json(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    req = Net::HTTP::Get.new(uri.request_uri, {
      "User-Agent" => "LocalDashboard/1.0",
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip"
    })

    res = http.request(req)
    raise "HTTP #{res.code}: #{res.body&.slice(0, 200)}" unless res.is_a?(Net::HTTPSuccess)

    body = if res["content-encoding"].to_s.downcase.include?("gzip")
             Zlib::GzipReader.new(StringIO.new(res.body)).read
           else
             res.body
           end

    JSON.parse(body)
  end
end
