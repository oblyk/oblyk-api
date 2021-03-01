# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

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

      get 'figures', controller: :commons, action: :figures
      get 'partners/geo_json', controller: :partners, actions: :geo_json

      resources :users, only: %i[show] do
        get :photos, on: :member
        get :videos, on: :member
        get :subscribes, on: :member
        get :followers, on: :member
        get :contribution, on: :member
        get :partner_user_geo_json, on: :member
        get :outdoor_figures, on: :member
        get :outdoor_climb_types_chart, on: :member
        get :ascended_crag_routes, on: :member
        get :outdoor_grades_chart, on: :member
      end

      resources :current_users, only: %i[] do
        collection do
          get '', action: :show
          put '', action: :update
          get :library
          get :subscribes
          get :followers
          get :favorites
          get :ascent_crag_routes
          get :ascended_crag_routes
          get :ascended_crags_geo_json
          get :tick_lists
          get :projects
          post :avatar
          post :banner
          namespace :log_books do
            resources :outdoors, only: %i[] do
              collection do
                get :figures
                get :climb_types_chart
                get :grades_chart
                get :years_chart
                get :months_chart
                get :evolutions_chart
              end
            end
          end
        end
      end

      resources :crags do
        get :search, on: :collection
        get :guides, on: :member
        get :photos, on: :member
        get :videos, on: :member
        get :versions, on: :member
        get :guide_books_around, on: :member
        get :areas_around, on: :member
        get :geo_json_around, on: :member
        get :geo_json, on: :collection
        get :geo_search, on: :collection
        resources :crag_routes do
          get :search, on: :collection
        end
        resources :parks do
          get :geo_json_around, on: :collection
        end
        resources :crag_sectors do
          get :geo_json_around, on: :collection
        end
        resources :approaches do
          get :geo_json_around, on: :collection
        end
      end
      resources :crag_sectors do
        get :versions, on: :member
        get :photos, on: :member
        get :videos, on: :member
        resources :crag_routes do
          get :search, on: :collection
        end
      end
      resources :crag_routes do
        get :versions, on: :member
        get :photos, on: :member
        get :videos, on: :member
      end
      resources :ascent_crag_routes
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
      resources :conversations, only: %i[index show create] do
        post :read, on: :member
        resources :conversation_messages
      end
      resources :videos
      resources :photos
      resources :areas do
        get :crags, on: :member
        get :photos, on: :member
        get :search, on: :collection
        post :add_crag, on: :member
        get :geo_json, on: :member
        delete :remove_crag, on: :member
      end
      resources :area_crags
      resources :subscribes, only: %i[index create]
      delete 'unsubscribes', controller: :subscribes, action: :unsubscribe
      resources :tags, only: %i[index create destroy]
      resources :tick_lists, only: %i[index create] do
        delete :destroy, on: :collection
      end
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
