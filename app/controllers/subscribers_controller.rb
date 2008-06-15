class SubscribersController < ApplicationController
  
  
  def index
    @lists = Page.find_all_by_class_name("SubscriberListPage")
  end
  
  def list
    @list = Page.find(params[:id])
    @subscribers = Subscriber.find_active_subscribers_by_subscriber_list(@list)
    @unsubscribers = Subscriber.find_unsubscribers_by_subscriber_list(@list)
  end
  
end
