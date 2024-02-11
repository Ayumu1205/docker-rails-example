class Customer::CheckoutsController < ApplicationController
  before_action :authenticate_customer!

  def create
    #line_items_checkoutを実行し、配列型line_itemsを取得
    line_items = current_customer.line_items_checkout
    session = create_session(line_items)
    # Allow redirection to the host that is different to the current host
    redirect_to session.url, allow_other_host: true
  end

  private

  def create_session(line_items)
    Stripe::Checkout::Session.create(
      client_reference_id: current_customer.id,
      customer_email: current_customer.email,
      mode: 'payment',
      payment_method_types: ['card'],
      line_items:,
      shipping_address_collection: {
        allowed_countries: ['JP']
      },
      shipping_options: [
        {
          shipping_rate_data: {
            type: 'fixed_amount',
            fixed_amount: {
              amount: 500,
              currency: 'jpy'
            },
            display_name: 'Single rate'
          }
        }
      ],
      #支払いが成功したときのリダイレクト先
      success_url: root_url,
      #支払いがキャンセルされたときのリダイレクト先
      cancel_url: "#{root_url}cart_items"
    )
  end
end