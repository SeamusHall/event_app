# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.site_key  = '6Lfb4R4UAAAAAO9MwcaS7rBX2NA6l1_lmK9AHkn7'
  config.secret_key = '6Lfb4R4UAAAAADpRaX6D8qxGOf8zrvRtd8vUa0sA'
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end
