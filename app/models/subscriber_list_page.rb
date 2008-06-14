class SubscriberListPage < Page
  
  ACTIONS = {
    :public => %w[ subscribe activate unsubscribe confirm_unsubscription ],
    :private => %w[ subscribed activated unsubscribed ]
  }
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    if url =~ /^#{self.url}(#{ACTIONS[:public].join("|")})\/([a-zA-Z0-9]{40,})?\/?$/
      @subscriber_list_action = $1
      @code = $2
      self
    else
      super
    end
  end
  
  def cache?
    false    
  end
  
  def process(request, response)
    @request, @response = request, response
    
    if request.post?
      if @subscriber_list_action == 'subscribe'
        parameters = request.parameters[:subscriber] || {}
        parameters[:subscriber_list_id] = self.id
        parameters[:subscribed_at] = Time.now
        @subscriber = Subscriber.new
        if @subscriber.update_attributes(parameters)
          @subscriber_list_action = 'subscribed'
        else
          @subscriber_list_errors = true
        end
        
      elsif @subscriber_list_action == 'unsubscribe'
        # todo: process unsubscription
      end
    else # request.get?
      if @subscriber_list_action == 'unsubscribe'
        
      end
    end
    
    super(request, response)
  end
  
  
  tag 'subscriber_list' do |tag|
    tag.expand
  end
  
  tag 'subscriber_list:unless_actions' do |tag|
    tag.expand unless (ACTIONS[:private] + ACTIONS[:public]).include?(@subscriber_list_action)
  end
  
  tag 'subscriber_list:if_actions' do |tag|
    tag.expand if (ACTIONS[:private] + ACTIONS[:public]).include?(@subscriber_list_action)
  end
  
  tag 'subscriber_list:if_form_errors' do |tag|
    tag.expand if @subscriber_list_errors
  end
  
  # todo: tag 'subscriber_list:form_errors'
  #       tag 'subscriber_list:form_errors:each'
  #       tag 'subscriber_list:form_errors:each:error_message'
  
  
  tag 'subscriber_list:unless_action' do |tag|
    action_name = tag.attr['name']
    tag.expand unless action_name == @subscriber_list_action
  end
  
  tag 'subscriber_list:if_action' do |tag|
    action_name = tag.attr['name']
    tag.expand if action_name == @subscriber_list_action
  end
  
end