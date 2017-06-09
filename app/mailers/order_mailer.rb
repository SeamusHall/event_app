class OrderMailer < ApplicationMailer

  def refund(order)
    @user = order.user
    @order = order
    mail(to: @user.email, subject: 'Order Refunded')
  end

  def decline(order)
    @user = order.user
    @order = order
    mail(to: @user.email, subject: 'Card Declined')
  end
end
