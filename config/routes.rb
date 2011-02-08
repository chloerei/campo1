Campo::Application.routes.draw do
  root :to => "home#index"

  get '/login', :controller => 'user_session', :action => 'new', :as => :login
  match '/logout', :controller => 'user_session', :action => 'destroy', :as => :logout
  resource :user_session, :controller => 'user_session', :only => [:create]

  get '/signup', :controller => 'users', :action => 'new'
  resources :users, :only => [:create]
  resource :account, :controller => 'users', :only => [:show, :update]

end
