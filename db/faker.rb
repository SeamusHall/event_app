100.times do
  @pass = Faker::Internet.password(12)
  @user = User.new(email: Faker::Internet.email, password: @pass, password_confirmation: @pass)
  @user.save
end
