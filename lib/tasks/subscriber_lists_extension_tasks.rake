namespace :radiant do
  namespace :extensions do
    namespace :subscriber_lists do
      
      desc "Runs the migration of the Subscriber Lists extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          SubscriberListsExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          SubscriberListsExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Subscriber Lists to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[SubscriberListsExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(SubscriberListsExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
