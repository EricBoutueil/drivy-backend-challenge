class Rental

  attr_accessor :id, :car, :start_date, :end_date, :distance, :commission

  def initialize(params, database)
    @id = params['id']

    # belongs_to :car
    @car = database.find('cars', params['car_id'])

    @start_date = Time.parse params['start_date']
    @end_date = Time.parse params['end_date']

    @distance = params['distance']

    # has_one :commission
    @commission = Commission.new(self)
  end

  def duration
    ((@end_date - @start_date)/(60*60*24)+1).to_i
  end

  def price
    calculated_ppd = 0

    duration.times do |d|
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

    amount = calculated_ppd + @distance * @car.price_per_km
    amount.to_i
  end

  def rental_calculator
    {id: @id, price: price, commission: @commission.commission_calculator}
  end

end
