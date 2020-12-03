# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :sessions do
        post 'refresh', controller: :refresh, action: :create
        post 'sign_in', controller: :signin, action: :create
        post 'sign_up', controller: :signup, action: :create
        delete 'sign_in', controller: :signin, action: :destroy
      end
      get 'rocks', controller: :rocks, action: :index
      get 'suns', controller: :suns, action: :index
      get 'rains', controller: :rains, action: :index
      get 'inclines', controller: :inclines, action: :index
      get 'climbs', controller: :climbs, action: :index
      get 'receptions', controller: :receptions, action: :index
      get 'starts', controller: :starts, action: :index
      get 'bolts', controller: :bolts, action: :index
      get 'anchors', controller: :anchors, action: :index
      get 'approach-types', controller: :approach_types, action: :index
      get 'alert-types', controller: :alert_types, action: :index

      get 'grade', controller: :grades, action: :grade
      get 'grade-types', controller: :grades, action: :types

      resources :users
      resources :crags
      resources :crag_sectors
      resources :crag_routes
      resources :words
      resources :comments
      resources :links
      resources :follows
      resources :parks
      resources :approaches
      resources :alerts
      resources :conversations
      resources :conversation_messages
      resources :areas
      resources :area_crags
      resources :subscribes, only: %i[index create]
      delete 'unsubscribes', controller: :subscribes, action: :unsubscribe
    end
  end
end
