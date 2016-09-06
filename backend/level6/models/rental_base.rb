class RentalBase

  def price
    @calculated_price ||= price_calculator
  end

  def price_calculator
    calculated_ppd = 0

    duration.times do |d|
      case d
        when 0
          calculated_ppd += @car.price_per_day
        when 1..3
          calculated_ppd += @car.price_per_day*0.9
        when 4..9
          calculated_ppd += @car.price_per_day*0.7
        else
          calculated_ppd += @car.price_per_day*0.5
      end
    end

    amount = calculated_ppd + @distance * @car.price_per_km
    amount.to_i
  end

  def deductible_reduction_calculator
    @deductible_reduction ? 400*duration : 0
  end

  def price_with_deductible_reduction
    price + deductible_reduction_calculator
  end

  def owner_gains
    price*0.7
  end

  def drivy_gains
    @commission.drivy_fee + deductible_reduction_calculator
  end

  def duration
    ((@end_date - @start_date)/(60*60*24)+1).to_i
  end

end