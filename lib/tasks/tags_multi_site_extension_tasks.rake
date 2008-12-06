namespace :radiant do
  namespace :extensions do
    namespace :tags_multi_site do
      
      desc "Runs the migration of the Tags Multi Site extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          TagsMultiSiteExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          TagsMultiSiteExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Tags Multi Site to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[TagsMultiSiteExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(TagsMultiSiteExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
