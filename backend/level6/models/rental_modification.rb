class RentalModification

  attr_accessor :id, :rental, :start_date, :end_date, :distance, :commission, :car

  def initialize(params, database)
    @id = params['id']

    # belongs_to :rental
    @rental = database.find('rentals', params['rental_id'])

    # delegate :car, to: :rental
    @car = @rental.car

    @start_date = params.key?('start_date') ? Time.parse(params['start_date']) : @rental.start_date
    @end_date = params.key?('end_date') ? Time.parse(params['end_date']) : @rental.end_date
    @distance = params.key?('distance') ? params['distance'] : @rental.distance

    # has_one :commission
    @commission = Commission.new(self)

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

  def deductible_reduction_calculator
    @rental.deductible_reduction ? 400*duration : 0
  end

  def duration
    ((@end_date - @start_date)/(60*60*24)+1).to_i
  end

  def new_actions
    actions = Array.new

    if price > rental.price
      # CASE 1 : New price is higher
      %w( driver owner insurance assistance drivy ).each do |a|
        type = (a == 'driver') ? 'debit' : 'credit'
        case a
          when 'driver'
            amount = price - rental.price + deductible_reduction_calculator - rental.deductible_reduction_calculator
          when 'owner'
            amount = -1*(rental.price*0.7 - price*0.7)
          when 'drivy'
            amount = @commission.drivy_fee - rental.deductible_reduction_calculator - rental.commission.drivy_fee + deductible_reduction_calculator
          else
            amount = @commission.send("#{a}_fee") - rental.commission.send("#{a}_fee")
        end
        actions << {who: a, type: type, amount: amount.to_i}
      end

    else
      # CASE 2 : New price is lower
      %w( driver owner insurance assistance drivy ).each do |a|
        type = (a == 'driver') ? 'credit' : 'debit'
        case a
          when 'driver'
            amount = rental.price + rental.deductible_reduction_calculator - price - deductible_reduction_calculator
          when 'owner'
            amount = -1*(price*0.7 - rental.price*0.7)
          when 'drivy'
            amount = rental.commission.drivy_fee - @commission.drivy_fee + rental.deductible_reduction_calculator - deductible_reduction_calculator
          else
            amount = rental.commission.send("#{a}_fee") - @commission.send("#{a}_fee")
        end
        actions << {who: a, type: type, amount: amount.to_i}
      end

    end
    actions
  end

  def rental_calculator
    {
        id: @id,
        rental_id: rental.id,
        actions: new_actions
    }
  end

end
