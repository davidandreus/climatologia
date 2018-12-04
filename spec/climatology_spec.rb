RSpec.describe Climatology do
  it "has a version number" do
    expect(Climatology::VERSION).not_to be nil
  end

  it "does something useful" do
    c = Climatology::Fetcher.new('metric', 'e6c1499f69e96c245c88c36a9bf14dbf')
    location = Climatology::Location.new
    location.city_id = 524901
    p c.fetch(location)

    expect(true).to eq(true)
  end

  it "connects to database" do
    # Inicializaciones
    db_handler = Climatology::DBHandler.new(database: "localhost", port: 8086)
    fetcher = Climatology::Fetcher.new('metric', 'e6c1499f69e96c245c88c36a9bf14dbf')
    location = Climatology::Location.new

    # Comienza el juego
    location.city_id = 524901
    weather = fetcher.fetch(location)
    db_handler.insert(location, weather)
    p db_handler.obtain(location)
  end
end
