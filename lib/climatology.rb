require "climatology/version"
require "open_weather"
require "influxdb"

module Climatology
  class Error < StandardError; end
  # Your code goes here...

  class Fetcher
    def initialize(units, appid)
      @options = {units: units, APPID: appid}
    end

    def fetch(location)
      response = OpenWeather::Current.city_id(location.city_id, @options)
      response_to_weather(response)
    end

    def response_to_weather(response)
      w = Weather.new
      w.temp = response["main"]["temp"]
      w.pressure = response["main"]["pressure"]
      w.humidity = response["main"]["humidity"]
      w.temp_min = response["main"]["temp_min"]
      w.temp_max = response["main"]["temp_max"]
      return w
    end
  end

  class Location
    attr_accessor :city_id
  end

  class Weather
    attr_accessor :temp
    attr_accessor :pressure
    attr_accessor :humidity
    attr_accessor :temp_min
    attr_accessor :temp_max

    def to_hash
      {
        temp: temp,
        pressure: pressure,
        humidity: humidity,
        temp_min: temp_min,
        temp_max: temp_max
      }
    end

    def self.from_hash whash
      w = Weather.new
      w.temp = whash["temp"]
      w.pressure = whash["pressure"]
      w.humidity = whash["humidity"]
      w.temp_min = whash["temp_min"]
      w.temp_max = whash["temp_max"]
      return w
    end
  end

  class DBHandler
    def initialize(params)
      params.merge!({
        host: "localhost",
        port: 8086
      })
      database = "weather"
      @client = InfluxDB::Client.new params
      @client.create_database(database)
      params[:database] = database
      @client = InfluxDB::Client.new params
    end

    def measurement_name(location)
      "current_weather_#{location.city_id}"
    end

    def insert(location, weather)
      name = measurement_name(location)
      data = {
        values: weather.to_hash
      }
      @client.write_point(name, data)
    end

    def obtain(location)
      query_str = "SELECT * FROM #{measurement_name(location)} ORDER BY time DESC LIMIT 1"
      @client.query query_str do |name, tags, points|
        points.each do |pt|
          return Weather.from_hash pt
        end
      end
    end
  end
end
