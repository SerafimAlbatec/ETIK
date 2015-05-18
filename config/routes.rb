Rails.application.routes.draw do

  devise_for :users
  get 'etic/home'
  get 'etic/material'
  get 'etic/kataskevastes'
  get 'etic/system'
  get 'etic/line'
  get 'etic/leaf'
  get 'etic/open_type'
  get 'etic/color'
  get 'etic/corol_kasas'
  get 'etic/color_fulou'
  get 'etic/diastaseis'
  get 'etic/extra'
  get 'etic/profil'
  get 'etic/tzamia'
  get 'etic/epikathimena'
  get 'etic/color_epikathimenou'
  get 'etic/color_eksoterikou'
  get 'etic/eksoterika'
  get 'etic/color_persidas'
  get 'etic/upologismos'
  get 'etic/typos'
  get 'etic/color_typos'
  get 'etic/color_odoigou'
  get 'etic/color_profil'
  get 'etic/profil'
  get 'etic/upologismos_platos_profil'
  get 'etic/upologismos_upsos_profil'
  get 'etic/color_epistrofi'
  get 'etic/price'
  get 'etic/card'
  get 'etic/pdf'
  get 'etic/export'
  delete 'etic/destroy'
  put 'etic/update'
  get 'etic/diagrafi'
  get 'etic/prosthiki_sto_kalathi'
  get 'etic/etic_card'
  get 'etic/etic_user_card'
  get 'etic/etic_pse_user_card'
  get 'etic/new_user'
  get 'etic/add_user'
  get 'etic/diagrafi_admin'
  get 'etic/update_admin'
  get 'etic/export_admin'
  get 'etic/pdf_admin'
  get 'etic/pse_done'
  get 'etic/contact'
  get 'etic/send_mail'
  get 'etic/pse_user'
  get 'etic/user_diax'
  get 'etic/simple_user_cr'
  get 'etic/add_simple_user'
  get 'etic/simple_pse_user_card'
  get 'etic/oloklirwsi_simple_user_pses'
  get 'etic/simple_pse_user'
  get 'etic/diagrafi_simple_user'
  get 'etic/pdf_simple_user'
  get 'etic/export_simple_user'
  post 'etic/save_image'
  get 'etic/select_customer'
  get 'etic/new_offer'
  get 'etic/import_terms'
  get 'etic/import_sungate'
  #root 'etic#home'
  get 'etic/language'
  devise_scope :user do
    root :to => 'devise/sessions#new'
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
