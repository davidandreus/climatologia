RSpec.describe Climatology do
  it "has a version number" do
    expect(Climatology::VERSION).not_to be nil
  end

  it "does something useful" do
    c = Climatology::WeatherAPI.new('metric', 'e6c1499f69e96c245c88c36a9bf14dbf')
    location = Climatology::Location.from_city_id(524901)
    p c.fetch([location])
    expect(true).to eq(true)
  end

  it "connects to database" do
    # Inicializaciones
    db_handler = Climatology::DBHandler.new(database: "localhost", port: 8086)
    weather_api = Climatology::WeatherAPI.new('metric', 'e6c1499f69e96c245c88c36a9bf14dbf')

    # Comienza el juego
    location = Climatology::Location.from_city_id(524901)
    weathers = weather_api.fetch([location])
    weathers.each do |weather|
      db_handler.insert(weather)
    end
    p db_handler.obtain(location)
  end
end
