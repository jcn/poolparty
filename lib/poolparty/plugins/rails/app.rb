module PoolParty
  module Resources
    
    class App < Rails
      
      default_options(
        :deploy_user   => nil,
        :deploy_group  => nil,
        :at            => "/var/www",
        :deploy_dirs   => false,
        :appended_path => nil,
        :log_dir       => nil
      )
      
      def after_loaded
        requires get_user(deploy_user)   if deploy_user
        requires get_group(deploy_group) if deploy_group

        build_directories
      end

      def site_directory
        "#{at}/#{name}%s" % [appended_path ? "/" + appended_path : ""]
      end
      
      private

      def build_directories
        has_directory(:name => at, :owner => deploy_user, :group => deploy_group, :mode => '0755')

        has_site_directory 

        if deploy_dirs
          has_site_directory "shared"
          has_site_directory "shared/log"
          has_site_directory "shared/system"
          has_site_directory "shared/pids"
          has_site_directory "shared/tmp"

          has_site_directory "releases"

          if not File.exists?("#{at}/#{name}/current")
            has_site_directory "releases/initial"
            has_site_directory "releases/initial/public"

            has_link(:name => "#{site_directory}/current", :to => "#{site_directory}/releases/initial") do
              requires get_site_directory("releases/initial")
              not_if   "/bin/sh -c '[ -L #{site_directory}/current ]'"
            end

            has_link(:name => "#{site_directory}/releases/initial/log", :to => "#{site_directory}/shared/log") do 
              requires get_site_directory("releases/initial")
            end

            has_link(:name => "#{site_directory}/releases/initial/public/system", :to => "#{site_directory}/shared/system") do 
              requires get_site_directory("releases/initial")
              requires get_site_directory("releases/initial/public")
            end

            has_link(:name => "#{site_directory}/releases/initial/tmp", :to => "#{site_directory}/shared/tmp") do 
              requires get_site_directory("releases/initial")
            end
          end

          appended_path "current"
          log_dir "#{site_directory}/shared/log"

        else
          has_site_directory 'log'
          log_dir "#{site_directory}/log"
        end
      end

      def has_site_directory(dir_name = '', opts = {})
        has_directory({ :name   => "#{site_directory}/#{dir_name}", 
                        :owner  => deploy_user, 
                        :group  => deploy_user, 
                        :mode   =>'0755',
                      }.merge(opts))
      end

      def get_site_directory(dir_name = '', opts = {})
        get_directory("#{site_directory}/#{dir_name}")
      end

      def get_site_directory_link(dir_name = '', opts = {})
        get_link("#{site_directory}/#{dir_name}")
      end
      
    end
    
  end
end
