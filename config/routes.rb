# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :sessions do
        post 'tokens', controller: :token, action: :refresh
        post 'sign_in', controller: :signin, action: :create
        post 'sign_up', controller: :signup, action: :create
        post 'reset_password', controller: :password, action: :create
        put 'new_password', controller: :password, action: :update
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
      get 'tags-list', controller: :tags_list, action: :index

      get 'grade', controller: :grades, action: :grade
      get 'grade-types', controller: :grades, action: :types
      get 'search', controller: :searches, action: :index

      resources :users, only: %i[index]
      get 'users/current', controller: :users, action: :show
      get 'users/current/subscribes', controller: :users, action: :subscribes
      get 'users/current/library', controller: :users, action: :library
      put 'users/current', controller: :users, action: :update
      post 'users/current/avatar', controller: :users, action: :add_avatar
      post 'users/current/banner', controller: :users, action: :add_banner

      resources :crags do
        get :search, on: :collection
        get :guides, on: :member
        get :photos, on: :member
        get :videos, on: :member
        get :versions, on: :member
        get :guide_books_around, on: :member
        get :geo_json_around, on: :member
        get :geo_json, on: :collection
        get :geo_search, on: :collection
        resources :parks
        resources :crag_routes
        resources :crag_sectors
      end
      resources :crag_sectors do
        get :versions, on: :member
        get :photos, on: :member
        get :videos, on: :member
        resources :crag_routes
      end

      resources :words do
        get :search, on: :collection
        get :versions, on: :member
      end
      resources :comments
      resources :links
      resources :follows, only: %i[index create] do
        put :increment, on: :collection
      end
      delete 'follows', controller: :follows, action: :destroy
      resources :parks
      resources :approaches
      resources :alerts
      resources :conversations
      resources :conversation_messages
      resources :videos
      resources :photos
      resources :areas
      resources :area_crags
      resources :subscribes, only: %i[index create]
      delete 'unsubscribes', controller: :subscribes, action: :unsubscribe
      resources :tags, only: %i[index create destroy]
      resources :tick_lists, only: %i[index create destroy]
      resources :guide_book_webs
      resources :guide_book_pdfs
      resources :guide_book_papers do
        get :crags, on: :member
        get :geo_json, on: :member
        get :photos, on: :member
        get :links, on: :member
        get :versions, on: :member
        get :search, on: :collection
        post :add_crag, on: :member
        post :add_cover, on: :member
        delete :remove_crag, on: :member
        delete :remove_cover, on: :member
        resources :place_of_sales
      end
      resources :gyms do
        get :versions, on: :member
        get :geo_json, on: :collection
        post :add_banner, on: :member
        post :add_logo, on: :member
        resources :gym_administrators
        resources :gym_administration_requests, only: %i[create]
        resources :gym_grades do
          resources :gym_grade_lines
        end
        resources :gym_spaces do
          put :publish, on: :member
          put :unpublish, on: :member
          post :add_banner, on: :member
          post :add_plan, on: :member
          resources :gym_sectors do
            delete :dismount_routes, on: :member
            resources :gym_routes
          end
          resources :gym_routes
        end
        resources :gym_routes do
          post :add_picture, on: :member
          post :add_thumbnail, on: :member
          put :dismount, on: :member
          put :mount, on: :member
        end
      end
      resources :reports, only: %i[create]
    end
  end
  mount Sidekiq::Web => '/sidekiq'
end
