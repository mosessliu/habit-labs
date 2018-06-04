Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'welcome#home'

  resources :users, only: [:show]
  post 'users/search', to: 'users#search'
  
  resources :habits, except: [:edit, :update]
  post 'habits/add_participant', to: 'habits#add_participant'
  post 'habits/remove_participant', to: 'habits#remove_participant'

  get 'back_to_edit_participants', to: 'habits#back_to_edit_participants'

  get 'build_habit_new', to: 'habits#build_habit_new'
  post 'build_habit_refresh', to: 'habits#build_habit_refresh'

  post 'create_refreshed_habit', to: 'habits#create_refreshed_habit'
  post 'accept_habit_invitation', to: 'habits#accept_habit_invitation'
  
  get 'refresh_habit', to: 'habits#refresh_habit'
  patch 'complete_habit', to: 'user_habit_deadlines#complete_habit'
  
  
  get 'notifications', to: 'notifications#notifications'
  get 'show_habit_invitation', to: 'notifications#show_habit_invitation'

end
