# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end
  mount Sidekiq::Web => '/sidekiq'

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
      get 'search', controller: :searches, action: :index

      get 'figures', controller: :commons, action: :figures
      get 'last_activity_feed', controller: :commons, action: :last_activity_feed
      get 'last_added', controller: :commons, action: :last_added
      get 'partners/figures', controller: :partners, action: :figures
      get 'partners/geo_json', controller: :partners, actions: :geo_json
      get 'partners/partners_around', controller: :partners, actions: :partners_around

      resources :organizations do
        get :api_access_token, on: :member
        put :refresh_api_access_token, on: :member
      end

      resources :authors, only: %i[show update] do
        post :add_cover, on: :member
      end
      resources :articles do
        get :feed, on: :collection
        get :last, on: :collection
        get :photos, on: :member
        get :crags, on: :member
        get :guide_book_papers, on: :member
        put :publish, on: :member
        put :un_publish, on: :member
        post :view, on: :member
        post :add_cover, on: :member
        post :add_crag, on: :member
        post :add_guide_book_paper, on: :member
      end

      resources :users, only: %i[show] do
        get :search, on: :collection
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
        get :indoor_figures, on: :member
        get :indoor_climb_types_chart, on: :member
        get :indoor_grade_chart, on: :member
        get :indoor_by_level_chart, on: :member
      end

      resources :current_users, only: %i[] do
        collection do
          get '', action: :show
          put '', action: :update
          delete '', action: :destroy
          get :feed
          get :library
          get :library_figures
          get :ascents_without_guides
          get :new_guide_books_version
          get :subscribes
          get :subscribes_ascents
          get :followers
          get :waiting_followers
          get :favorite_crags
          get :favorite_gyms
          get :ascent_crag_routes
          get :ascended_crag_routes
          get :ascended_crags_geo_json
          get :tick_lists
          get :projects
          get :photos
          get :videos
          post :avatar
          post :banner
          put :update_password
          get :subscribe_to_newsletter
          get :organizations
          post :accept_followers
          delete :reject_followers
          namespace :log_books do
            resources :outdoors, only: %i[] do
              collection do
                get :figures
                get :climb_types_chart
                get :grades_chart
                get :years_chart
                get :months_chart
                get :evolutions_chart
                get :daily_ascents
                get :ascents_of_crag
              end
            end
            resources :indoors, only: %i[] do
              collection do
                get :figures
                get :climb_types_chart
                get :years_chart
                get :months_chart
                get :grades_chart
                get :by_levels_chart
                get :simple_stats_by_gyms
              end
            end
          end
          resources :climbing_sessions, only: %i[index show update]
        end
      end

      resources :notifications, only: %i[index] do
        get :unread_count, on: :collection
        put :read, on: :member
        put :read_all, on: :collection
      end

      resources :ascent_crag_routes do
        post :add_ascent_user, on: :member
        delete :remove_ascent_user, on: :member
        get :export, on: :collection
      end

      resources :ascent_gym_routes do
        post :create_bulk, on: :collection
      end

      resources :comments
      resources :links
      resources :follows, only: %i[index create] do
        put :increment, on: :collection
      end
      delete 'follows', controller: :follows, action: :destroy
      resources :alerts
      resources :conversations, only: %i[index show create] do
        post :read, on: :member
        resources :conversation_messages do
          get :last_messages, on: :collection
        end
      end
      resources :videos
      resources :photos
      resources :subscribes, only: %i[index create] do
        delete :destroy, on: :collection
      end
      resources :newsletters do
        get :photos, on: :member
        post :send_newsletter, on: :member
      end
      resources :tick_lists, only: %i[index create] do
        delete :destroy, on: :collection
      end
      resources :gyms do
        get :versions, on: :member
        get :search, on: :collection
        get :geo_json, on: :collection
        get :gyms_around, on: :collection
        post :add_banner, on: :member
        post :add_logo, on: :member
        get :routes_count, on: :member
        get :routes, on: :member
        resources :color_systems, only: %i[index create show]
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
          get :ascents, on: :member
          post :add_picture, on: :member
          post :add_thumbnail, on: :member
          put :dismount, on: :member
          put :mount, on: :member
          put :dismount_collection, on: :collection
          put :mount_collection, on: :collection
        end
      end
      resources :color_systems, only: %i[index show create]
      resources :reports, only: %i[create]

      scope :public do
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

        resources :area_crags
        resources :areas do
          get :crags, on: :member
          get :crags_figures, on: :member
          get :guide_book_papers, on: :member
          get :photos, on: :member
          get :search, on: :collection
          post :add_crag, on: :member
          get :geo_json, on: :member
          delete :remove_crag, on: :member
          resources :crag_routes, only: %i[index] do
            get :search_by_grades, on: :collection
          end
        end

        resources :towns, only: %i[show] do
          get :search, on: :collection
          get :geo_search, on: :collection
          get :geo_json, on: :member
        end

        resources :countries, only: %i[index show] do
          get :route_figures, on: :member
          get :geo_json, on: :member
          resources :departments, only: %i[index show] do
            get :route_figures, on: :member
            get :geo_json, on: :member
          end
        end

        resources :departments, only: %i[index show] do
          get :route_figures, on: :member
        end

        resources :crags do
          get :search, on: :collection
          post :advanced_search, on: :collection
          get :random, on: :collection
          get :guides, on: :member
          get :photos, on: :member
          get :videos, on: :member
          get :articles, on: :member
          get :versions, on: :member
          get :route_figures, on: :member
          get :guide_books_around, on: :member
          get :areas_around, on: :member
          get :geo_json_around, on: :member
          get :geo_json, on: :collection
          get :geo_search, on: :collection
          get :crags_around, on: :collection
          resources :crag_routes do
            get :search, on: :collection
            get :search_by_grades, on: :collection
          end
          resources :parks do
            get :geo_json_around, on: :collection
          end
          resources :crag_sectors do
            get :geo_json_around, on: :collection
            resources :crag_routes, only: %i[] do
              get :search_by_grades, on: :collection
            end
          end
          resources :approaches do
            get :geo_json_around, on: :collection
          end
        end

        resources :crag_sectors do
          get :versions, on: :member
          get :photos, on: :member
          get :videos, on: :member
          get :route_figures, on: :member
          resources :crag_routes do
            get :search, on: :collection
            get :search_by_grades, on: :collection
          end
        end

        resources :crag_routes do
          get :versions, on: :member
          get :photos, on: :member
          get :videos, on: :member
          get :random, on: :collection
        end

        resources :parks
        resources :approaches

        resources :guide_book_webs
        resources :guide_book_pdfs
        resources :guide_book_papers do
          get :grouped, on: :collection
          get :crags, on: :member
          get :crags_figures, on: :member
          get :geo_json, on: :member
          get :photos, on: :member
          get :links, on: :member
          get :articles, on: :member
          get :versions, on: :member
          get :alternatives, on: :member
          get :search, on: :collection
          get :around, on: :collection
          post :add_crag, on: :member
          post :add_cover, on: :member
          delete :remove_crag, on: :member
          delete :remove_cover, on: :member
          resources :place_of_sales
        end

        resources :words do
          get :search, on: :collection
          get :versions, on: :member
        end
      end
    end
  end
end
