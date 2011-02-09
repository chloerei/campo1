Campo::Application.routes.draw do
  root :to => "home#index"

  get '/login', :controller => 'user_sessions', :action => 'new', :as => :login
  match '/logout', :controller => 'user_sessions', :action => 'destroy', :as => :logout
  resource :user_session, :only => [:create]

  get '/signup', :controller => 'users', :action => 'new'
  resources :users, :only => [:create]
  scope '/settings' do
    resource :account, :controller => 'users', :only => [:show, :update]
    resource :password, :only => [:show, :update]
  end

end
