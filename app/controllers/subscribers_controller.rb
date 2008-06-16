class SubscribersController < ApplicationController
  require 'fastercsv'
  
  before_filter :find_subscriber_list, :only => [:new, :edit, :destroy]
  
  def index
    @lists = Page.find_all_by_class_name("SubscriberListPage")
  end

  def list
    @list = Page.find(params[:id])
    @subscribers = Subscriber.find_active_subscribers_by_subscriber_list(@list)
    @unsubscribers = Subscriber.find_unsubscribers_by_subscriber_list(@list)
  end
  
  def new
    @subscriber = Subscriber.new
  end

  def create
    params[:subscriber][:subscribed_at] = Time.now()
    @subscriber = Subscriber.new(params[:subscriber])
    if @subscriber.save
      flash[:notice] = 'Subscriber has been saved correctly.'
      redirect_to :action => 'list', :id => @subscriber.subscriber_list_id
    else
      flash[:error] = 'Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing.'
      render :action => 'new'
    end
  end

  def edit
    @subscriber = Subscriber.find(params[:id])
  end

  def update
    @subscriber = Subscriber.find(params[:id])
    @subscriber_list = Page.find(params[:subscriber][:subscriber_list_id])
    if @subscriber.update_attributes(params[:subscriber])
      flash[:notice] = 'Subscriber has been updated correctly.'
      redirect_to :action => 'list', :id => @subscriber.subscriber_list_id
    else
      flash[:error] = 'Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing.'
      render :action => 'edit'
    end
  end
  
  
  def unsubscribe
    if @subscriber = Subscriber.find(params[:id])
      @subscriber.update_attributes({:unsubscribed_at => Time.now})
      redirect_to :action => :list, :id => @subscriber.subscriber_list_id
    end
  end
  
  def resubscribe
    if @subscriber = Subscriber.find(params[:id])
      @subscriber.update_attributes({:unsubscribed_at => nil})
      redirect_to :action => :list, :id => @subscriber.subscriber_list_id
    end
  end
  
  def delete_subscriber
    if @subscriber = Subscriber.find(params[:id])
      @subscriber.destroy
      redirect_to :action => :list, :id => @subscriber.subscriber_list_id
    end
  end

  def export
    @list = Page.find(params[:id])
    subscribers = Subscriber.find_active_subscribers_by_subscriber_list(@list)
    stream_csv do |csv|
      csv << ["email","name"]
      subscribers.each do |subscriber|
        csv << [subscriber.email,subscriber.name]
      end
    end
  end

  private

  def stream_csv
  filename = params[:action] + ".csv"
  filename = "#{@list.title}-subscribers-#{Time.now().strftime("%d%b%y")}.csv"
    #this is required if you want this to work with IE
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end

    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n")
      yield csv
    }
  end
  
  
  def find_subscriber_list
    @subscriber_list = Page.find(params[:subscriber_list_id])
    redirect_to('/admin/') and return if @subscriber_list.class_name != 'SubscriberListPage'
  rescue ActiveRecord::RecordNotFound  
    redirect_to('/admin')
  end

end
