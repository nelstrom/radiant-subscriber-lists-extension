class SubscribersController < ApplicationController
  require 'fastercsv'

  def index
    @lists = Page.find_all_by_class_name("SubscriberListPage")
  end

  def list
    @list = Page.find(params[:id])
    @subscribers = Subscriber.find_active_subscribers_by_subscriber_list(@list)
    @unsubscribers = Subscriber.find_unsubscribers_by_subscriber_list(@list)
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


end
