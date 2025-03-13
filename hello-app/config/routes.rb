Rails.application.routes.draw do
  root to: "hello_world#index"

  match "*path", to: "hello_world#index", via: :all
end
