Shelr::Application.routes.draw do

  resources :records do
    resources :comments

    get :search, :on => :collection
    get :embed,  :on => :member
  end

  resources :users

  resource :session, :only => [:create, :destroy] do
    get :login, on: :collection
  end

  match '/auth/:provider/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'

  match '/about'     => 'home#about',     as: 'about'
  match '/dashboard' => 'home#dashboard', as: 'dashboard'

  match '/comments/preview' => 'comments#preview'

  match '/opensearch.xml'  => 'home#opensearch', as: 'opensearch'

  root :to => "home#landing"
end
