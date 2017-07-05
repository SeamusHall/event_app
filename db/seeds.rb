# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Role.where(name: 'admin').first_or_create(description: 'the all powerful admin')
Role.where(name: 'reg').first_or_create(description: 'regular user role')

# Thanks to mrvncaragay
# https://github.com/mrvncaragay/rails-redis-search/blob/master/db/seeds.rb
def add_users_to_redis(user)
  1.upto(user.email.length)       { |n| $redis.zadd(user.email[0, n], n,                    "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
  unless user.check_nullity?
    1.upto(user.full_name.length)   { |n| $redis.zadd(user.full_name[0, n].to_s.downcase, n,  "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.phone.length)       { |n| $redis.zadd(user.phone[0, n].to_s, n,               "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.first_name.length)  { |n| $redis.zadd(user.first_name[0, n].downcase, n,      "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.last_name.length)   { |n| $redis.zadd(user.last_name[0, n].downcase, n,       "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.city.length)        { |n| $redis.zadd(user.city[0, n].downcase, n,            "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.postal_code.length) { |n| $redis.zadd(user.postal_code[0, n].to_s, n,         "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.state.length)       { |n| $redis.zadd(user.state[0, n].to_s.downcase, n,      "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
    1.upto(user.country.length)     { |n| $redis.zadd(user.country[0, n].to_s.downcase, n,    "#{user.id},#{user.full_name},#{user.phone},#{user.email},#{user.gravatar_url}") }
  end
end

def add_orders_to_redis(order)
  1.upto(order.user.first_name.length)  { |n| $redis.zadd(order.user.full_name[0, n].to_s.downcase, n, "") }
  1.upto(order.user.email.length)       { |n| $redis.zadd(order.user.email[0, n], n, "") }
  1.upto(order.user.phone.length)       { |n| $redis.zadd(order.user.phone[0, n].to_s, n, "") }
  1.upto(order.user.first_name.length)  { |n| $redis.zadd(order.user.first_name[0, n].downcase, n, "") }
  1.upto(order.user.last_name.length)   { |n| $redis.zadd(order.user.last_name[0, n].downcase, n, "") }
  1.upto(order.user.postal_code.length) { |n| $redis.zadd(order.user.postal_code[0, n].to_s, n, "") }
  1.upto(order.user.city.length)        { |n| $redis.zadd(order.user.city[0, n].downcase, n, "") }
  1.upto(order.user.state.length)       { |n| $redis.zadd(order.user.state[0, n].to_s.downcase, n, "") }
  1.upto(order.user.country.length)     { |n| $redis.zadd(order.user.country[0, n].to_s.downcase, n, "") }
end

users = User.all
users.each { |user| add_users_to_redis(user) }

#orders = Order.all + OrderProduct.all
#orders.each { |order| add_orders_to_redis(order) }
