ActionController::Routing::Routes.draw do |map|

  #deprecated
  map.resources :galleries, :member => {:set_cover => :get, :move_a_pic => :get, :add_pics => :get,  :edit_pics => :get,  :do_add_pics => :put   }

  #deprecated
  map.resources :pictures, :member => { :suspend   => :get,
    :unsuspend => :get, :activate => :get  }

  #  map.resources :members, :member =>{ #:create_relation => :get,
  #    #:update_relation => :get,
  #    :create_or_update => :get,
  #    :create_or_update_current_user => :get,
  #    :destroy_relation => :get,
  #    :destroy_current_user_relation => :get,
  #    :accept => :get,
  #    :refuse => :get}


  map.resources :organisms, :collection => { :list   => :get} do |organism|
    organism.resources :mailings, :collection => { :prep_to_members   => :get,
      :send_to_members => :put }
    organism.resources :events, :controller => 'organism_events'
    organism.resources :posts, :member => { :suspend   => :get,
      :unsuspend => :get, :activate => :get  }do |post|
      post.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
    organism.resources :galleries, :member => {:set_cover => :get, :move_a_pic => :get, :add_pics => :get,  :edit_pics => :get,  :do_add_pics => :put   } do |gallery|
      gallery.resources :pictures, :member => { :suspend   => :get,
        :unsuspend => :get, :activate => :get  } do |picture|
        picture.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
          :unsuspend => :get,
          :activate     => :get }
      end
      gallery.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
    organism.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
      :unsuspend => :get,
      :activate     => :get }
    organism.resources :members, :collection =>{ #:create_relation => :get,
      #:update_relation => :get,
      :create_or_update => :get,
      :create_or_update_current_user => :get,
      :destroy_relation => :get,
      :destroy_current_user_relation => :get,
      :accept => :get,
      :refuse => :get}
    organism.resources :pictures, :member => { :suspend   => :get,
      :unsuspend => :get, :activate => :get  }do |picture|
      picture.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
    organism.resources :maps
  end


  map.resources :users do |user|
    user.resources :memberships
    user.resources :friends
    #user.resources :other_friends
    user.resources :participations
    user.resources :organisms_terms, :controller => 'user_organisms_terms'
    user.resources :posts, :member => { :suspend   => :get,
      :unsuspend => :get, :activate => :get  }do |post|
      post.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
  end


  map.resources :events, :member => {:share => :get, :do_share => :put, :cancel => :put} do |event|
    event.resources :participations
    event.resources :galleries, :member => {:set_cover => :get, :move_a_pic => :get, :add_pics => :get,  :edit_pics => :get,  :do_add_pics => :put   } do |gallery|
      gallery.resources :pictures, :member => { :suspend   => :get,
        :unsuspend => :get, :activate => :get  }do |picture|
        picture.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
          :unsuspend => :get,
          :activate     => :get }
      end
      gallery.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
    event.resources :comments, :member => { :remote_suspend   => :get,
      :suspend   => :get,
      :unsuspend => :get,
      :activate     => :get } 
    event.resources :posts, :member => { :suspend   => :get,
      :unsuspend => :get, :activate => :get  } do |post|
      post.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
    event.resources :pictures, :member => { :suspend   => :get,
      :unsuspend => :get, :activate => :get  }do |picture|
      picture.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
    event.resources :terms, :controller => 'event_terms' do |term|
      term.resources :participations
    end
    event.resources :maps
  end

  #deprecated
  map.resources :terms do |term|
    term.resources :participations
  end


  map.resources :participations, :collection =>{
    :create_or_update => :get }
    

  #deprecated
  map.resources :terms

  map.resources :activities

  map.resources :searchs


  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users do |user|
    user.resources :pictures, :member => { :suspend   => :get,
      :unsuspend => :get, :activate => :get  }do |picture|
      picture.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
        :unsuspend => :get,
        :activate     => :get }
    end
  end

  map.resource :session

  map.connect '', :controller=>'facebook', :conditions=> { :canvas => true }, :member => { :ask_facebook_event_categories => :get }

  map.resources :organisms, :member => { :suspend   => :put,
    :unsuspend => :put,
    :purge     => :delete }

  map.activate '/activate_organism/:activation_code', :controller => 'organisms', :action => 'activate', :activation_code => nil

  map.resources :categories do |category|
    category.resources :date, :controller => 'categories'
  end

  map.resources :rating, :collection =>{
    :rate => :get }

  #deprecated
  map.resources :comments, :member => { :remote_suspend => :get, :suspend   => :get,
    :unsuspend => :get,
    :activate     => :get }

  map.activate '/activate_user/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  map.resources :users, :member => { :suspend   => :put,
    :unsuspend => :put,
    :purge     => :delete }, :collection => {:ask_facebook_info => :get}

  map.root :controller => "terms", :action => "index"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
 
end
