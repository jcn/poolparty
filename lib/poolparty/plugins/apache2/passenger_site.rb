module PoolParty
  module Resources
    # Usage:
    #
    # passenger_site do
    #   port              "80"
    #   environment       "production"
    #   site_directory    "/var/www"
    #   log_dir           "/var/log/apache2"
    #   passenger_version "2.2.4"
    # end
    class PassengerSite < Apache
      
      default_options(
        :port           => "80",
        :environment    => 'production',
        :site_directory => "/var/www",
        :log_dir        => "/var/log/apache2",
        :passenger_version => "2.2.4"
      )
      
      def after_loaded
        enable_passenger
        
        pass_entry = <<-EOE
  <VirtualHost *:#{port}>
      ServerName #{name}
      DocumentRoot #{site_directory}/public
      RailsEnv #{environment}
      ErrorLog #{log_dir}/error_log
      CustomLog #{log_dir}/access_log common
  </VirtualHost>
        EOE
        
        passenger_entry(pass_entry)
        
        install_site(name, :no_file => true) # we already created the file with #passenger_entry
      end
      
      def passenger_entry(file)
        if ::File.file?(file)
          has_file({:name => "/etc/apache2/sites-available/#{name}", :template => file})
        else
          has_file({:content => file, :name => "/etc/apache2/sites-available/#{name}" })
        end
      end
      
    end
    
  end
  
end
