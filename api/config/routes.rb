# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # get '/pictures', to: 'pages#pictures'

  # Defines the root path route ("/")
  root 'pages#home'
end
