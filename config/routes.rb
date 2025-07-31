# config/routes.rb
Rails.application.routes.draw do
  post '/signup', to: 'authentication#signup'
  post '/login', to: 'authentication#login'

  resource :me, controller: 'users', only: [:show, :update]

  resources :projects do
    resources :project_members, path: 'members', only: [:index, :create, :update, :destroy]
    resources :tasks do
      resources :checklist_items, path: 'checklists', only: [:index, :create, :update, :destroy]
      resources :comments, only: [:index, :create] # Comments on tasks
    end
    resources :comments, only: [:index, :create] # Comments on projects
  end

  # For updating/deleting a specific comment (assuming ID is known)
  resources :comments, only: [:update, :destroy]
end