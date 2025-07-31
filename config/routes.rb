
Rails.application.routes.draw do
  post '/signup', to: 'authentication#signup'
  post '/login', to: 'authentication#login'

  resource :me, controller: 'users', only: [:show, :update]

  resources :projects do
    resources :project_members, path: 'members', only: [:index, :create, :update, :destroy]
    resources :tasks do
      resources :checklist_items, path: 'checklists', only: [:index, :create, :update, :destroy]
      resources :comments, only: [:index, :create] 
    end
    resources :comments, only: [:index, :create] 
  end

  
  resources :comments, only: [:update, :destroy]
end