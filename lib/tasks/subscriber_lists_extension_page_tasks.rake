require 'yaml'

namespace :radiant do
  namespace :extensions do
    namespace :subscriber_lists do
      namespace :page do
        # rake radiant:extensions:subscriber_lists:page:new
        desc %Q{Creates a new Subscriber List page, with all necessary page parts
          You can set the parent for the Subscriber List page by passing PARENT_ID= id_of_parent_page. By default, it will use the home page as parent.
          }
        task :new => :environment do
          pages_fixture = File.join(SubscriberListsExtension.root, 'spec', 'fixtures', 'pages.yml')
          page_parts_fixture = File.join(SubscriberListsExtension.root, 'spec', 'fixtures', 'page_parts.yml')
          pages = YAML.load_file(pages_fixture)
          page_parts = YAML.load_file(page_parts_fixture)
          newsletter_page_attributes = pages["newsletter"]
          
          newsletter_page_attributes["parent_id"]  = ENV["PARENT_ID"] if ENV["PARENT_ID"]
          newsletter_page_attributes["title"]      = ENV["TITLE"] if ENV["TITLE"]
          if ENV["SLUG"]
            newsletter_page_attributes["slug"] = ENV["SLUG"]
          else
            newsletter_page_attributes["slug"] = newsletter_page_attributes["title"].downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
          end
          
          if ENV["BREADCRUMB"]
            newsletter_page_attributes["breadcrumb"] = ENV["BREADCRUMB"]
          else
            newsletter_page_attributes["breadcrumb"] = newsletter_page_attributes["title"]
          end
          
          page = Page.new
          if page.update_attributes(newsletter_page_attributes)
            puts "Page has been created succesfully"
            puts "Creating page parts..."
            %w[
              newsletter_body
              newsletter_subscribe newsletter_subscribed
              newsletter_unsubscribe newsletter_unsubscribed
            ].each do |part_name|
              print '.'
              page_part_attributes = page_parts[part_name]
              page_part_attributes["page_id"] = page.id
              page.parts.create(page_part_attributes)
            end
            puts;puts "Page parts have been created"
          else
            puts "There are some errors:"
            page.errors.each{|k, v| puts " * #{v}"}
          end
          
          
        end
        
      end
    end
  end
end