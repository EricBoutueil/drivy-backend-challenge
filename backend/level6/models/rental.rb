class Rental < RentalBase

  attr_accessor :id, :car, :start_date, :end_date, :distance, :commission, :deductible_reduction, :calculated_price

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

  def actions
    actions = Array.new
    %w( driver owner insurance assistance drivy ).each do |a|
      type = (a == 'driver') ? 'debit' : 'credit'
      case a
        when 'driver'
          amount = price_with_deductible_reduction
        when 'owner'
          amount = owner_gains
        when 'drivy'
          amount = drivy_gains
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
