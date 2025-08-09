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

  # equivalent of cloudflare "Transform via URL" for the development environment
  # see : https://developers.cloudflare.com/images/transform-images/transform-via-url/
  # only a few options are supported (fit=crop or fit=scale-down and quality)
  get 'cdn-cgi/image/:options/:key', controller: 'cdn_cgi/images', action: :variante_path
  namespace :services do
    namespace :stripes do
      post :webhook, to: 'webhooks#index'
    end
  end

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
      get 'search_all', controller: :searches, action: :search_all
      get 'search_around', controller: :searches, action: :search_around

      get 'figures', controller: :commons, action: :figures
      get 'micro_stats', controller: :commons, action: :micro_stats
      get 'last_activity_feed', controller: :commons, action: :last_activity_feed
      get 'last_added', controller: :commons, action: :last_added
      get 'active_gyms', controller: :commons, action: :active_gyms
      get 'partners/figures', controller: :partners, action: :figures
      get 'partners/partners_around', controller: :partners, actions: :partners_around
      resources :tools, only: %i[] do
        get :qr_coder, on: :collection
      end

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
        get :localities, on: :member
        get :stats, on: :member
        get :ascended_crag_routes, on: :member
        get :indoor_figures, on: :member
        get :indoor_climb_types_chart, on: :member
        get :indoor_grade_chart, on: :member
        get :indoor_by_level_chart, on: :member
      end
      resources :locality_users do
        put :deactivate, on: :member
        put :activate, on: :member
      end
      resources :localities, only: %i[index show] do
        get :geo_json, on: :collection
        get :climbers, on: :member
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
          get :likes
          get :waiting_followers
          get :favorite_crags
          get :favorite_gyms
          get :upcoming_contests
          get :ascent_crag_routes
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
          get :partner_around_localities
          get :partner_figures
          put :partner_checked
          post :accept_followers
          delete :reject_followers
          get :gym_administrators
          put :switch_email_report
          get :suggested_friends
          namespace :log_books do
            resources :outdoors, only: %i[] do
              collection do
                get :stats
                get :ascended_crag_routes
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
        get :points, on: :collection
        post :create_bulk, on: :collection
      end

      resources :comments do
        get :comments, on: :member
        delete :moderate_by_gym_administrator, on: :member
      end
      resources :likes, only: %i[index create] do
        delete '/:likeable_type/:likeable_id', action: :destroy, on: :collection
      end
      resources :links
      resources :follows, only: %i[index create] do
        get :followers, on: :collection
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
      resources :videos do
        delete :moderate_by_gym_administrator, on: :member
      end
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
      resources :contests, only: %i[] do
        get :opens, on: :collection
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
        get :tree_structures, on: :member
        get :tree_routes, on: :member
        get :ascent_scores, on: :member
        get :figures, on: :member
        get :comments, on: :member
        get :videos, on: :member
        get :three_d, on: :member
        get :stripe_customer_portal, on: :member
        resources :gym_billing_accounts, only: %i[show create update]
        resources :indoor_subscriptions, only: %i[index show create update] do
          get :figures, on: :collection
        end
        resources :indoor_subscription_products, only: %i[index show]
        resources :gym_three_d_elements
        resources :gym_three_d_assets do
          put :change_three_d_file, on: :member
          post :add_picture, on: :member
        end
        resources :color_systems, only: %i[index create show]
        resources :gym_levels, only: %i[index] do
          put :update_all, on: :collection
        end
        resources :gym_administrators do
          put :update_feed_last_read, on: :collection
          get :new_in_feeds, on: :collection
        end
        resources :gym_administration_requests, only: %i[create]
        resources :gym_climbing_styles, only: %i[index create] do
          put :deactivate, on: :collection
        end
        resources :gym_openers do
          put :deactivate, on: :member
          put :activate, on: :member
        end
        resources :gym_label_templates do
          get :model, on: :collection
          get :print, on: :member
          put :archived, on: :member
          put :unarchived, on: :member
          post :copy, on: :member
        end
        resources :gym_grades do
          resources :gym_grade_lines
        end
        resources :gym_spaces do
          get :groups, on: :collection
          get :tree_sectors, on: :collection
          get :three_d_elements, on: :member
          put :archived, on: :member
          put :unarchived, on: :member
          post :add_banner, on: :member
          post :add_plan, on: :member
          post :add_three_d_file, on: :member
          post :add_three_d_capture, on: :member
          resources :gym_sectors do
            put :bulk_update, on: :collection
            get :last_routes_with_pictures, on: :member
            delete :dismount_routes, on: :member
            delete :delete_three_d_path, on: :member
            resources :gym_routes do
              get :paginated, on: :collection
            end
          end
          resources :gym_routes do
            get :paginated, on: :collection
          end
        end
        resources :gym_space_groups
        resources :gym_routes do
          get :paginated, on: :collection
          get :print, on: :collection
          get :export, on: :collection
          get :ascents, on: :member
          get :similar_sectors, on: :member
          get :comments, on: :member
          post :add_picture, on: :member
          post :add_thumbnail, on: :member
          put :dismount, on: :member
          put :mount, on: :member
          put :dismount_collection, on: :collection
          put :mount_collection, on: :collection
          post :opening_sheet_collection, on: :collection
          delete :delete_picture, on: :member
        end
        resources :gym_opening_sheets do
          get :print, on: :member
          put :update_cells, on: :member
          put :archived, on: :member
          put :unarchived, on: :member
        end
        namespace :statistics do
          resources :gym_route_statistics, only: [] do
            post :figures, on: :collection
            post :routes_by_grades, on: :collection
            post :routes_by_levels, on: :collection
            post :notes, on: :collection
            post :like_figures, on: :collection
            post :difficulty_figures, on: :collection
            post :appreciation_figures, on: :collection
            post :opening_frequencies, on: :collection
          end
        end
        resources :contests do
          get :time_line, on: :member
          get :results, on: :member
          get :export_results, on: :member
          get :statistics, on: :member
          put :draft, on: :member
          put :archived, on: :member
          put :unarchived, on: :member
          post :add_banner, on: :member
          resources :contest_categories
          resources :contest_waves
          resources :contest_teams
          resources :contest_judges do
            post :add_routes, on: :member
            delete :delete_route, on: :member
          end
          resources :contest_judge_interfaces, only: %i[show] do
            post :unlock, on: :member
            get :participants, on: :member
          end
          resources :contest_participant_ascents, only: %i[index]
          resources :contest_participant_steps, only: %i[] do
            post :subscribe, on: :collection
          end
          resources :contest_participants do
            get :export, on: :collection
            post :import, on: :collection
            post :tombola, on: :collection
            get :tombola_winners, on: :collection
            get :import_template, on: :collection
            get :participant, on: :member
            post :subscribe, on: :collection
            resources :contest_participant_ascents, only: %i[create] do
              post :bulk, on: :collection
            end
          end
          resources :contest_stages do
            resources :contest_stage_steps do
              resources :contest_route_groups do
                post :add_route, on: :member
              end
            end
          end
          resources :contest_routes do
            put :linked, on: :member
            put :unlinked, on: :member
            put :disable, on: :member
            put :enable, on: :member
            post :add_picture, on: :member
            delete :delete_picture, on: :member
          end
        end
        resources :championships do
          get :results, on: :member
          get :contests, on: :member
          get :available_contests, on: :member
          post :add_banner, on: :member
          post :add_contest, on: :member
          put :archived, on: :member
          put :unarchived, on: :member
          resources :championship_contests, only: %i[create] do
            delete :delete, on: :collection
          end
          resources :championship_categories do
            get :contest_categories, on: :collection
          end
        end
      end
      resources :gym_label_fonts, only: %i[index]
      resources :gym_roles, only: %i[index]
      resources :color_systems, only: %i[index show create]
      resources :gym_administrations, only: %i[] do
        get :assigned, on: :collection
        get :requested, on: :collection
        put :accept_request, on: :collection
        delete :delete_request, on: :collection
        post :add_option, on: :collection
        delete :delete_option, on: :collection
      end
      resources :gym_chains, only: %i[show update] do
        post :add_banner, on: :member
        post :add_logo, on: :member
        get :gyms_geo_json, on: :member
      end
      resources :reports, only: %i[create]

      scope :public do
        get 'rocks', controller: :rocks, action: :index
        get 'suns', controller: :suns, action: :index
        get 'rains', controller: :rains, action: :index
        get 'inclines', controller: :inclines, action: :index
        get 'climbs', controller: :climbs, action: :index
        get 'climbing_styles', controller: :climbing_styles, action: :index
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
          get :additional_geo_json_features, on: :collection
          get :geo_json, on: :collection
          get :geo_search, on: :collection
          get :crags_around, on: :collection
          resources :rock_bars, only: %i[index show create update destroy]
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
          get :search, on: :collection
          get :suggested_routes, on: :collection
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
          get :geo_index, on: :collection
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
