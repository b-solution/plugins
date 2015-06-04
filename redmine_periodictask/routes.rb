ActionController::Routing::Routes.draw do |map|
    map.resources :periodictask, :controller => 'periodictask', :collection => { :any => :any}
    map.connect 'projects/:project_id/new', :controller=> 'periodictask', :action => 'new', :conditions => {:method => :get}
    map.connect 'projects/:project_id/', :controller=> 'periodictask', :action => 'new', :conditions => {:method => :get}
end
