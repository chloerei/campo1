Campo::Application.routes.draw do
  root :to => "home#index"

  get '/login', :controller => 'user_sessions', :action => 'new', :as => :login
  match '/logout', :controller => 'user_sessions', :action => 'destroy', :as => :logout
  resource :user_session, :only => [:create]

  get '/signup', :controller => 'users', :action => 'new'
  resources :users, :only => [:create]
  namespace :settings do
    resource :account, :only => [:show, :update]
    resource :password, :only => [:show, :update]
    resource :profile, :only => [:show, :update]
  end

  resources :topics, :except => [:destroy]
  resources :replies, :only => [:new, :create, :edit, :update]

  get '~:username' => 'people#show', :as => :person
  get '~:username/topics' => 'people#topics', :as => :person_topics

end
