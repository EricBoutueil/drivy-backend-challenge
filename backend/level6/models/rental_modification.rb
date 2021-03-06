class RentalModification < RentalBase

  attr_accessor :id, :rental, :start_date, :end_date, :distance, :commission, :car, :calculated_price

  def initialize(params, database)
    @id = params['id']

    # belongs_to :rental
    @rental = database.find('rentals', params['rental_id'])

    # delegate :car, to: :rental
    @car = @rental.car

    # delegate :deductible_reduction, to: :rental
    @deductible_reduction = @rental.deductible_reduction

    @start_date = params.key?('start_date') ? Time.parse(params['start_date']) : @rental.start_date
    @end_date = params.key?('end_date') ? Time.parse(params['end_date']) : @rental.end_date
    @distance = params.key?('distance') ? params['distance'] : @rental.distance

    # has_one :commission
    @commission = Commission.new(self)
  end

  def new_actions
    price > @rental.price ? debit_driver : refund_driver
  end

  def rental_calculator
    {
        id: @id,
        rental_id: @rental.id,
        actions: new_actions
    }
  end

  private

  def refund_driver
    # When new price is lower
    actions = Array.new
    %w( driver owner insurance assistance drivy ).each do |a|
      type = (a == 'driver') ? 'credit' : 'debit'
      case a
        when 'driver'
          amount = @rental.price_with_deductible_reduction - price_with_deductible_reduction
        when 'owner'
          amount = -1*(owner_gains - @rental.owner_gains)
        when 'drivy'
          amount = @rental.drivy_gains - drivy_gains
        else
          amount = @rental.commission.send("#{a}_fee") - @commission.send("#{a}_fee")
      end
      actions << {who: a, type: type, amount: amount.to_i}
    end
    actions
  end

  def debit_driver
    # When new price is higher
    actions = Array.new
    %w( driver owner insurance assistance drivy ).each do |a|
      type = (a == 'driver') ? 'debit' : 'credit'
      case a
        when 'driver'
          amount = price_with_deductible_reduction - @rental.price_with_deductible_reduction
        when 'owner'
          amount = -1*(@rental.owner_gains - owner_gains)
        when 'drivy'
          amount = drivy_gains - @rental.drivy_gains
        else
          amount = @commission.send("#{a}_fee") - @rental.commission.send("#{a}_fee")
      end
      actions << {who: a, type: type, amount: amount.to_i}
    end
    actions
  end

end
