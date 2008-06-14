class Subscriber < ActiveRecord::Base
  validates_presence_of :email
  # validates_uniqueness_of :email
  validates_presence_of :subscriber_list_id

  #TODO: add validation to newsletter.Does the newsletter page exists?
  
  validates_format_of :email, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => Proc.new{|ns| !ns.email.blank? }
  
end
