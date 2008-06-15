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
        if @subscriber = Subscriber.find_active_subscriber_by_subscriber_list_and_email(self, 
          request.parameters[:subscriber][:email])
          @subscriber.update_attributes({:unsubscribed_at => Time.now()})
          @subscriber_list_action = 'unsubscribed'
        else
          @subscriber_list_errors = true
        end
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
  
  
  
  desc %Q{Render the contents of this tag if the URL does not match the action given
    in the attribute @name@.}
  tag 'subscriber_list:unless_action' do |tag|
    action_name = tag.attr['name']
    tag.expand unless action_name == @subscriber_list_action
  end
  
  desc %Q{
    Render the contents of this tag if the URL matches the action given
    in the attribute @name@.
  }
  tag 'subscriber_list:if_action' do |tag|
    action_name = tag.attr['name']
    tag.expand if action_name == @subscriber_list_action
  end
  
  desc %Q{
    Only renders the contents if the form raised an error when submitted.
  }
  tag 'subscriber_list:if_form_errors' do |tag|
    tag.expand if @subscriber_list_errors
  end
  
  desc %Q{
    Creates @<form>@ tags for a subscription form, with the action attribute 
    set to the appropriate URL for subscribing to this list.
  }
  tag 'subscriber_list:subscribe_form' do |tag|
    "<form action=\"/#{self.slug}/subscribe\" method=\"post\">
    #{tag.expand}
    </form>"
  end
  
  desc %Q{
    Creates an input tag for the email address, as follows:
    
    <pre><input type="text" name="subscriber[email]" id="subscriber_email"/></pre>
    
    There is an advantage to using this radiant tag, instead of inputting the HTML directly:
    if the form has been submitted but it returned errors, then this tag will populate the
    input with the erroneous values so that the user may correct it. The plain HTML tag would
    reset the input, which would be irritating.
    
    *Usage:*
    <pre><r:subscriber_list:input_email [id="custom_id"]/></pre>
  }
  tag 'subscriber_list:input_email' do |tag|
    if subscriber = request.parameters["subscriber"]
      if email = subscriber["email"]
        value = "value=\"#{email}\""
      end
    end
    id = tag.attr['id'] || "subscriber_email"
    "<input type=\"text\" name=\"subscriber[email]\" id=\"#{id}\" #{value}/>"
  end
  
  desc %Q{
    Creates an input tag for the name, as follows:
    
    <pre><input type="text" name="subscriber[name]"/></pre>
    
    There is an advantage to using this radiant tag, instead of inputting the HTML directly:
    if the form has been submitted but it returned errors, then this tag will populate the
    input with the erroneous values so that the user may correct it. The plain HTML tag would
    reset the input, which would be irritating. 
    
    *Usage:*
    <pre><r:subscriber_list:input_name [id="custom_id"]/></pre>
  }
  tag 'subscriber_list:input_name' do |tag|
    if subscriber = request.parameters["subscriber"]
      if name = subscriber["name"]
        value = "value=\"#{name}\""
      end
    end
    id = tag.attr['id'] || "subscriber_name"
    "<input type=\"text\" name=\"subscriber[name]\" id=\"#{id}\" #{value}/>"
  end
  
  desc %Q{
    Creates @<form>@ tags for an unsubscription form, with the action attribute 
    set to the appropriate URL for unsubscribing from this list.
  }
  tag 'subscriber_list:unsubscribe_form' do |tag|
    "<form action=\"/#{self.slug}/unsubscribe\" method=\"post\">
    #{tag.expand}
    </form>"
  end
  
  
  desc %Q{
    The contents of this tag are displayed only if the form has errors
  }
  tag 'subscriber_list:form_errors' do |tag|
    if @subscriber_list_errors
      errors = {}
      @subscriber.errors.each {|k,v| errors[k] = v }
      tag.locals.errors = errors
      tag.expand
    end
  end
  
  desc %Q{
    If there were errors in submitting the form, then you can cycle 
    through them using this tag. Use the tag @<r:error_message/>@ within.
  }
  tag 'subscriber_list:form_errors:each' do |tag|
    result = []
    errors = tag.locals.errors
    errors.each do |field, error|
      tag.locals.error = error
      tag.locals.field = field
      result << tag.expand
    end
    result
  end
  
  desc %Q{
    Shows an error message on the current form.
  }
  tag 'subscriber_list:form_errors:each:error_message' do |tag|
    "#{tag.locals.field} #{tag.locals.error}"
  end
  
  desc %Q{
    Only shows the contents if a subscriber model can be found 
    (i.e. if a form has been submitted) and if an email can be found
    for that subscriber.
  }
  tag 'subscriber_list:if_email' do |tag|
    if subscriber = request.parameters["subscriber"]
      if subscriber["email"]
        tag.expand
      end
    end
  end
  
  desc %Q{
    Show the email of the current subscriber
  }
  tag 'subscriber_list:email' do |tag|
    request.parameters["subscriber"]["email"]
  end
  
  desc %Q{
    Only shows the contents if a subscriber model can be found 
    (i.e. if a form has been submitted) and if an name can be found
    for that subscriber.
  }
  tag 'subscriber_list:if_name' do |tag|
    if subscriber = request.parameters["subscriber"]
      if subscriber["name"]
        tag.expand
      end
    end
  end
  
  desc %Q{Show the name of the current subscriber}
  tag 'subscriber_list:name' do |tag|
    request.parameters["subscriber"]["name"]
  end
  
  
end