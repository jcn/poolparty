module PoolParty
  module Resources

    # Usage:
    #
    # rails do
    #   rails_version "2.3.4"
    #
    #   app "railsapp" do 
    #     deploy_user "deploy"               # User who owns the deploy directories
    #     deploy_group "deploy"              # Group that owns the deploy directories
    #     at           "/home/deploy/apps"   # App will be deployed into "/home/deploy/apps/railsapp"
    #     deploy_dirs  true                  # Build capistrano-like directory structure (boolean)
    #   end
    #
    # end

    class Rails < Resource
      
      default_options(
        :rails_version => "2.3.4"
      )
      
      def after_loaded
        has_package "libsqlite3-dev"

        has_gem_package "rails", :version => rails_version
        has_gem_package "sqlite3-ruby", :requires => get_package("libsqlite3-dev")
      end
      
    end
    
  end
end

require "#{File.dirname(__FILE__)}/rails/app"
