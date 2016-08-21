class Rental

  attr_accessor :id, :car, :start_date, :end_date, :distance, :commission, :deductible_reduction

  def initialize(params, database)
    @id = params['id']

    # belongs_to :car
    @car = database.find('cars', params['car_id'])

    @start_date = Time.parse params['start_date']
    @end_date = Time.parse params['end_date']

    @distance = params['distance']

    @deductible_reduction = params['deductible_reduction']

    # has_one :commission
    @commission = Commission.new(self)
  end

  def deductible_reduction_calculator
    @deductible_reduction ? 400*duration : 0
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

  def actions
    actions = Array.new
    %w( driver owner insurance assistance drivy ).each do |a|
      type = (a == 'driver') ? 'debit' : 'credit'
      case a
        when 'driver'
          amount = price + deductible_reduction_calculator
        when 'owner'
          amount = price - price*0.3
        when 'drivy'
          amount = @commission.drivy_fee + deductible_reduction_calculator
        else
          amount = @commission.send("#{a}_fee")
      end
      actions << {who: a, type: type, amount: amount.to_i}
    end
    actions
  end

  # Used on level 5
  def rental_calculator
    {
        id: @id,
        actions: actions
    }
  end

  # Used on level 1..4
  # def rental_calculator
  #   {id: @id, price: price, options: {deductible_reduction: deductible_reduction_calculator}, commission: @commission.export}
  # end

end
