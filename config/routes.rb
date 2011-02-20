Campo::Application.routes.draw do
  root :to => "topics#index"

  get '/login', :controller => 'user_sessions', :action => 'new', :as => :login
  match '/logout', :controller => 'user_sessions', :action => 'destroy', :as => :logout
  resource :user_session, :only => [:create]

  get '/signup', :controller => 'users', :action => 'new'
  resources :users, :only => [:create]
  namespace :settings do
    resource :account, :only => [:show, :update]
    resource :password, :only => [:show, :update]
    resource :profile, :only => [:show, :update]
    resource :favorite_tags, :only => [:show, :create, :destroy]
  end

  resources :topics, :except => [:destroy] do
    collection do
      get 'tagged/:tag', :action => 'tagged', :as => :tagged
      get :interesting
      get :own
      get :newest
      get :collection
    end

    member do
      post :mark
      delete :mark, :action => 'unmark'
    end
  end
  resources :replies, :only => [:new, :create, :edit, :update]

  get '~:username' => 'people#show', :as => :person
  get '~:username/topics' => 'people#topics', :as => :person_topics

  match '*path', :to => 'errors#routing'
end
