Rails.application.routes.draw do
  require 'sidekiq/web'

  post 'register', to: 'users#register'
  post 'login', to: 'users#login'
  post 'password_reset', to: 'users#password_reset'
  post 'logout', to: 'users#logout'
  get 'check_status', to: 'users#check_status'
  resources :chat_rooms do
    resources :messages, only: [:index, :create]
    post 'add_member', on: :member
  end

  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'

end
