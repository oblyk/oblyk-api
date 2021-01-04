# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :sessions do
        post 'tokens', controller: :token, action: :refresh
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
      get 'tags-list', controller: :tags_list, action: :index

      get 'grade', controller: :grades, action: :grade
      get 'grade-types', controller: :grades, action: :types
      get 'search', controller: :searches, action: :index

      resources :users, only: %i[index]
      get 'users/current', controller: :users, action: :show
      put 'users/current', controller: :users, action: :update

      resources :crags
      resources :crag_sectors
      resources :crag_routes
      resources :words do
        get :search, on: :collection
      end
      resources :comments
      resources :links
      resources :follows
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
        post :add_crag, on: :member
        delete :remove_crag, on: :member
        post :add_cover, on: :member
        delete :remove_cover, on: :member
      end
      resources :gyms do
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
    end
  end
end
