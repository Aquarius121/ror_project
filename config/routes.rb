require 'sidekiq/web'
require 'sidekiq-status/web'

Butlermaps::Application.routes.draw do

  resources :galleries
  resources :premium_plans
  resources :coupons
  resources :activities
  resources :announcements
  resources :attachments
  resources :shared_rides
  resources :referrals
  resources :avatars

  resources :challenges do
    member do
      post 'join'
      get 'leaderboard'
      delete 'leave'
    end
  end

  resources :riding_groups do
    member do
      post 'riders/:rider_id', to: 'riding_groups#add_rider'
      delete 'riders/:rider_id', to: 'riding_groups#remove_rider'
    end
    collection do
      get 'active'
    end
  end

  get 'users/me/app-settings', to: 'app_settings#index'
  post 'users/me/app-settings', to: 'app_settings#create'

  get 'routes/:route_id/popularity', to: 'popularity#index'
  post 'routes/:route_id/popularity', to: 'popularity#create'
  delete 'routes/:route_id/popularity', to: 'popularity#destroy'

  post 'user_location/:latlng', to: 'user_location#create', :constraints => { :latlng => /[0-9\-\.,]+/ }
  get 'user_location', to: 'user_location#index'

  get '/embed/shot/:route_id', to: 'embed#shot'
  get '/embed/:route_id', to: 'embed#index'

  get 'weather/:latlng', to: 'weather#index', :constraints => { :latlng => /[0-9\-\.,]+/ }
  get 'weather', to: 'weather#index'

  post 'unsubscribe', to: 'payments#unsubscribe'
  post 'subscribe', to: 'payments#subscribe'

  post 'confirm_buy', to: 'users#status_pro'
  post 'is_premium', to: 'users#is_premium'

  post 'notifications/:route_id', to: 'notifications#create'

  resources :invites do
    collection do
      get 'notapproved', to: 'invites#notapproved'
      get 'approve/:id', to: 'invites#approve'
    end
  end

  resources :members do
    collection do
      get 'listforapprove/:club_id', to: 'members#listforapprove'
      post 'approve/:club_id', to: 'members#approve'
    end
  end

  resources :friendships do
    collection do
      get 'approve'
      post 'approve'
      post 'approvecount'
      get 'myfriends'
      get 'suggest'
    end
  end

  resources :addresses do
    collection do
      get 'city/:state', to: 'addresses#city'
      get 'cities', to: 'addresses#cities'
    end
  end

  resources :clubs do
    member do
      get 'rides', to: 'group_rides#index'
      post 'rides/:route_id', to: 'group_rides#create'
      delete 'rides/:route_id', to: 'group_rides#destroy'
    end
    collection do
      get 'search'
      post 'search'
      post 'logoupload'
    end
  end

  resources :routes do
    resources :comments
    collection do
      post 'show_own'
      get 'search'
      post 'search'
      post 'search_butler'
      get 'show_my_routes'
      get 'my_rides'
      get 'g1_markers'
      get 'friends/:friend_id/rides', to: 'routes#friend_rides'
      post 'upload_img/:id', to: 'routes#upload_img'
      post 'delete_img/:id', to: 'routes#delete_img'
      post 'upload'
    end
    member do
      get 'nearby', to: 'routes#nearby'
      post 'copy'
      get 'download'
      post 'push'
    end
  end

  resources :shared_rides do
    collection do
      get 'new/:id', to: 'shared_rides#new'
      post 'share_via_email'
      post 'newsharecount'
      post 'see_rides'
      post 'sharegetfriends/:id', to: 'shared_rides#sharegetfriends'
      get 'shareautocomplete/find', to: 'shared_rides#shareautocomplete'
    end
  end

  resources :comments do
    collection do
      get 'new/:related_id', to: 'comments#new', as: :comments_new_comment
      get 'show_for_route/:related_id', to: 'comments#show_for_route', as: :comments_see_for_route
    end
  end

  resources :announcements do
    collection do
      get 'new/:club_id', to: 'announcements#new'
      get 'show_for_club/:club_id', to: 'announcements#show_for_club'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :tokens, :only => [:create, :destroy]
    end
  end

  get '/bg_uploads/new', to: 'bg_upload#new'
  post '/bg_uploads/create', to: 'bg_upload#create'
  get 'friends/view'
  get 'friends/route/:id', to: 'friends#route'
  get 'friends/', to: 'friends#index'
  get 'omniauth_callbacks/facebook'
  get 'homepage/index'

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'registrations',
    sessions: 'sessions'
  }

  devise_scope :user do
    get '/registrations/invite', to: 'registrations#invite'
    get '/signup-as-premium', to: 'registrations#combined'
    post '/registrations/inviterequest', to: 'registrations#inviterequest'
    get '/registrations/frominvite/:id', to: 'registrations#frominvite'
    get '/users/edit/:id', to: 'registrations#edit'
    put '/users/:id', to: 'registrations#update'
    delete '/users/:id', to: 'registrations#destroy'
    authenticated :user do
      root to: 'homepage#index', as: :authenticated_root
    end
    unauthenticated :user do
      root to: 'sessions#new', as: :unauthenticated_root
    end
  end

  resources :users do
    collection do
      get 'search'
      get 'additional'
      get 'role', to: 'users#role'
      get 'all_emails'
      get 'nearby/:latlng', to: 'user_location#nearby', :constraints => { :latlng => /[0-9\-\.,]+/ }
    end
    member do
      post 'promote', to: 'users#promote_to_admin'
      post 'demote', to: 'users#demote_to_free'
      post 'make_pro', to: 'users#make_pro'
      get 'challenges', to: 'challenges#index'
    end
  end

  root 'homepage#index'

  get 'rebuild' => 'data#form'
  post 'api/build' => 'data#build'
  get 'api/build' => 'data#build'
  get 'api/jobs' => 'data#jobs'
  get 'api/proxy' => 'proxy#index'
  post 'api/proxy' => 'proxy#index'
  post 'authorize-net/' => 'silent_post#save_to_db'

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  authenticate :user, lambda { |u| u.role?(:admin) }  do
    mount Sidekiq::Web => 'sidekiq'
    mount PgHero::Engine, at: 'pghero'
  end

  namespace 'admin' do
    resource :user_session, only: [:create, :destroy]
  end

  namespace :v2 do
    root to: 'dashboards#index', as: :root

    resource :profile, only: [:show, :update]

    resource :subscription, only: [:show, :update, :destroy] do
      get :upgrade
    end

    resources :challenges, only: [:index, :show] do
      member do
        get :accept
      end
    end

    resources :clubs, path: 'groups' do
      member do
        post    :invite
        patch   :join
        delete  :leave
        get     :announcements
      end
    end

    resources :feeds, only: [:index, :show]

    resources :announcements, only: :show

    # resources :announcements, only: :index

    resources :users, only: [:index, :show] do
      member do
        patch  :befriend
        delete :unfriend
      end
    end

    resources :friends
    resources :rides

    resources :routes do
      resources :comments
      collection do
        post 'show_own'
        get  'search'
        post 'search'
        post 'search_butler'
        get  'show_my_routes'
        get  'my_rides'
        get  'g1_markers'
        get  'friends/:friend_id/rides', to: 'routes#friend_rides'
        post 'upload_img/:id', to: 'routes#upload_img'
        post 'delete_img/:id', to: 'routes#delete_img'
        post 'upload'
      end

      member do
        get  'nearby', to: 'routes#nearby'
        post 'copy'
        get  'download'
        post 'push'
      end
    end

    controller :login do
      get :signin
      get :signup
    end

    scope :markup, controller: :markup, as: :markup do
      root action: :index
      get :dashboard


      get :group
      get :group_form
      get :challenge
      get :feed
      get :friend
      get :subscription
      get :upgrade
      get :account
      get :group_search
      get :challenges

      # TODO
      get :trip
      get :map
    end
  end
end
