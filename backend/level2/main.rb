require 'json'
require 'Time'
require './database'
require './models/car'
require './models/rental'


class Main

  def initialize
    # I chose to create an object 'Database' which load a json file, parse the datas into objects based on my models
    @data = Database.new('./data.json')
  end

  # Function used to create the output.json
  def export_prices
    h = {rentals: []}
    @data.rentals.each do |r|
      h[:rentals] << r.rental_calculator
    end

    output = File.open('output.json','w')
    output << JSON.generate(h)
    output.close

    'Prices exported'
  end

end
