
namespace :acts_as_queryable do
  desc 'Migrate acts_as_queryable to current status and sync extra files.'
  task :all => [ 'acts_as_queryable:migrate', 'acts_as_queryable:sync' ]
  
  desc 'Migrate acts_as_queryable to current status.'
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("vendor/plugins/acts_as_queryable/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  desc "Sync extra files from acts_as_queryable plugin"
  task :sync do
    system "rsync -ruv vendor/plugins/acts_as_queryable/assets/javascripts public"
    system "rsync -ruv vendor/plugins/acts_as_queryable/assets/stylesheets public"
  end

  desc "Link extra files from acts_as_queryable plugin for development"
  task :develop do
    system "ln -svf #{File.join Dir.pwd, 'vendor/plugins/acts_as_queryable/assets/javascripts/*'} public/javascripts"
    system "ln -svf #{File.join Dir.pwd, 'vendor/plugins/acts_as_queryable/assets/stylesheets/*'} public/stylesheets"
  end
end