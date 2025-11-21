class Payment < ApplicationRecord
  belongs_to :tenant

  attr_accessor :token

  validates :card_number, :card_cvv, :card_expires_month, :card_expires_year,
          presence: true,
          if: -> { tenant&.plan == 'premium' }

  def process_payment
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    customer = Stripe::Customer.create(
      email: tenant.email,
      source: token
    )

    Stripe::Charge.create(
      customer: customer.id,
      amount: 1000, # cents
      currency: 'usd',
      description: "Premium Plan Payment for #{tenant.name}"
    )
  end

  def self.month_options
    (1..12).map { |m| [sprintf('%02d', m), m] }
  end

  def self.year_options
    (Date.today.year..Date.today.year+10).to_a
  end
end