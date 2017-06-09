class OrderProductMailer < ApplicationMailer

  def refund(op)
    @user = op.user
    @op = op
    mail(to: @user.email, subject: 'Order Refund')
  end

  def decline(op)
    @user = op.user
    @op = op
    mail(to: @user.email, subject: 'Card Declined')
  end
end
