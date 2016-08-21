class Commission

  attr_accessor :insurance_fee, :assistance_fee, :drivy_fee, :rental

  def initialize(rental)
    # belongs_to :rental
    @rental = rental
    commission_calculator
  end

  def export
    {insurance_fee: @insurance_fee.to_i, assistance_fee: @assistance_fee.to_i, drivy_fee: @drivy_fee.to_i}
  end

  private

  def commission_calculator
    commission_amount = @rental.price * 0.3

    @insurance_fee = commission_amount * 0.5
    @assistance_fee = @rental.duration * 100
    @drivy_fee = commission_amount - @insurance_fee - @assistance_fee
  end


end