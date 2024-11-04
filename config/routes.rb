Rails.application.routes.draw do
  post 'register', to: 'users#register'
  post 'login', to: 'users#login'
  post 'password_reset', to: 'users#password_reset'
end
