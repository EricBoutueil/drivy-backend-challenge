class Car
  attr_accessor :id
  attr_accessor :price_per_day
  attr_accessor :price_per_km

  def initialize(params)
    @id = params['id']
    @price_per_day = params['price_per_day']
    @price_per_km = params['price_per_km']
  end
end