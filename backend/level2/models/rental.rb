class Rental

  attr_accessor :id, :car, :start_date, :end_date, :distance

  def initialize(params, database)
    @id = params['id']

    # belongs_to :car
    @car = database.find('cars', params['car_id'])

    @start_date = Time.parse params['start_date']
    @end_date = Time.parse params['end_date']

    @distance = params['distance']
  end

  def rental_calculator

    days = ((@end_date - @start_date)/(60*60*24)+1).to_i
    calculated_ppd = 0

    days.times do |d|
      case d
        when 0
          calculated_ppd += @car.price_per_day
        when 1..3
          calculated_ppd += (@car.price_per_day - @car.price_per_day*0.1)
        when 4..9
          calculated_ppd += (@car.price_per_day - @car.price_per_day*0.3)
        else
          calculated_ppd += (@car.price_per_day - @car.price_per_day*0.5)
      end
    end

    price = calculated_ppd + @distance * @car.price_per_km
    {id: @id, price: price.to_i}
  end

end
