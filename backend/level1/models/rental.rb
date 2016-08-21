class Rental

  attr_accessor :id, :car, :start_date, :end_date, :distance

  def initialize(params, database)
    @id = params['id']

    # belongs_to :car
    @car = database.find('cars' ,params['car_id'])

    @start_date = Time.parse params['start_date']
    @end_date = Time.parse params['end_date']

    @distance = params['distance']
  end

  def rental_calculator
    price = ((@end_date - @start_date)/(60*60*24)+1) * @car.price_per_day + @distance * @car.price_per_km
    {id: @id, price: price.to_i}
  end

end