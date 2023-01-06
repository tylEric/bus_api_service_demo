Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "/current_bus_stops_info", to: "buses#get_bus_stops_info"
  post "/subscribe_current_stop", to: "buses#subscribe"
  post "/unsubscribe_current_stop", to: "buses#unsubscribe"
end
