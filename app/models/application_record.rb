class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # https://github.com/mrvncaragay/rails-redis-search/blob/master/app/models/search.rb
  def self.redis_search(term)
    objects = $redis.zrevrange(term, 0, 20)
    ucount = $redis.zcount(term, 0, 10)
    objects = strtoarr(objects) unless objects.empty?
    uhash = {ucount: ucount, data: objects}
  end

  def self.strtoarr(objects)
    arry = []
    objects.each do |o|
      arry << o.split(',')
    end
    arry
  end
end
