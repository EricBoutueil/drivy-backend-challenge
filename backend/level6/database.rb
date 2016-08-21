class Database

  attr_accessor :rentals, :rental_modifications, :cars

  def initialize(file_path)
    @rentals = Array.new
    @cars = Array.new
    @rental_modifications = Array.new

    load_and_parse_data(file_path)
  end

  # Find an object by id for a given collection (please refer on attr_accessor)
  def find(collection_name, id)
    collection = eval("@#{collection_name}")
    unless collection.nil?
      position = collection.index { |c| c.id == id }
      return position ? collection[position] : 'Undefined'
    end
    "Undefined collection named #{collection_name}"
  end

  private

  def load_and_parse_data(file_path)
    source = JSON.parse(File.new(file_path, 'r').read)

    source['cars'].each do |c|
      @cars << Car.new(c)
    end

    source['rentals'].each do |r|
      @rentals << Rental.new(r, self)
    end

    source['rental_modifications'].each do |rm|
      @rental_modifications << RentalModification.new(rm, self)
    end
  end

end
