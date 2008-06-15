# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class SubscriberListsExtension < Radiant::Extension
  version "1.0"
  description "Allows you to create one or more lists to which your site's visitors may subscribe, by submitting their email address."
  url "http://github.com/nelstrom/radiant-subscriber-lists-extension/tree/master"
  
  define_routes do |map|
    map.connect 'admin/subscribers/:action', :controller => 'subscribers'
  end
  
  def activate
    SubscriberListPage
    admin.tabs.add "Subscribers", "/admin/subscribers", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Subscribers"
  end
  
end