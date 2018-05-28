Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'welcome#home'

  resources :users, only: [:show]
  post 'users/search', to: 'users#search'
  
  resources :habits, except: [:edit, :update]
  post 'habits/add_participant', to: 'habits#add_participant'
  get 'build_habit', to: 'habits#build_habit'
  get 'accept_habit_invitation', to: 'habits#accept_habit_invitation'
  
  patch 'complete_habit', to: 'user_habit_deadlines#complete_habit'
  
  get 'notifications', to: 'notifications#notifications'
  get 'show_habit_invitation', to: 'notifications#show_habit_invitation'

end
