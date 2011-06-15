Campo::Application.routes.draw do
  root :to => "statuses#index"

  get '/login', :controller => 'user_sessions', :action => 'new', :as => :login
  match '/logout', :controller => 'user_sessions', :action => 'destroy', :as => :logout
  resource :user_session, :only => [:create]

  resources :notifications
  resource :reset_password

  get '/signup', :controller => 'users', :action => 'new'
  resources :users, :only => [:create]
  namespace :settings do
    resource :account, :only => [:show, :update]
    resource :password, :only => [:show, :update]
    resource :profile, :only => [:show, :update]
    resource :favorite_tags, :only => [:show, :create, :destroy]
  end

  resources :statuses, :only => [:index, :show]

  get '/search', :to => 'topics#search', :as => :search
  resources :topics, :except => [:destroy] do
    collection do
      get 'tagged/:tag', :action => 'tagged', :as => :tagged, :constraints  => { :tag => /[^\/]+/ }, :format => false
      get :interesting
      get :newest
    end

    member do
      post :mark
      delete :mark, :action => 'unmark'
    end
  end
  resources :replies, :only => [:new, :create, :edit, :update]

  get '~:username' => 'people#show', :as => :person
  get '~:username/topics' => 'people#topics', :as => :person_topics
  get '~:username/statuses' => 'people#statuses', :as => :person_statuses
  get '~:username/followers' => 'people#followers', :as => :person_followers
  get '~:username/followings' => 'people#followings', :as => :person_followings
  post '~:username/follow' => 'people#follow', :as => :follow_person
  delete '~:username/follow' => 'people#unfollow'

  namespace :admin do
    get '/' => 'dashboard#show', :as => :dashboard
    resources :topics, :only => [:index, :show, :destroy] do
      member do
        post :close
        post :open
      end
    end
    resources :replies, :only => [:index, :show, :destroy]
    resources :users, :only => [:index, :show, :destroy] do
      member do
        post :ban
        delete :ban, :action => :unban
        post :ban_and_clean
      end
    end
    resource :site_config, :controller => 'site_config'
  end

  match '*path', :to => 'errors#routing'
end
