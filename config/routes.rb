Rails.application.routes.draw do
  post 'register', to: 'users#register'
  post 'login', to: 'users#login'
  post 'password_reset', to: 'users#password_reset'
  resources :chat_rooms do
    post 'add_member', on: :member
  end
end
