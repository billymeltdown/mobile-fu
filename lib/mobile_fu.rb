module ActionController
  module MobileFu
    
    # These are various strings that can be found in mobile devices.  Please feel free
    # to add on to this list.
    
    
    MOBILE_USER_AGENTS =  'palm|palmos|palmsource|iphone|blackberry|nokia|phone|midp|mobi|pda|' +
                          'wap|java|nokia|hand|symbian|chtml|wml|ericsson|lg|audiovox|motorola|' +
                          'samsung|sanyo|sharp|telit|tsm|mobile|mini|windows ce|smartphone|' +
                          '240x320|320x320|mobileexplorer|j2me|sgh|portable|sprint|vodafone|' +
                          'docomo|kddi|softbank|pdxgw|j-phone|astel|minimo|plucker|netfront|' +
                          'xiino|mot-v|mot-e|portalmmm|sagem|sie-s|sie-m|android|ipod'
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      # Add this to one of your controllers to include MobileFu, and run the before_filter
      #
      #    class SessionController < ApplicationController 
      #      has_mobile_fu
      #      before_filter :set_mobile_format, :only => [ :foo, :bar ]
      #    end
      #
      # You can also force mobile mode by calling a different before_filter
      #
      #    class ApplicationController < ActionController::Base 
      #      has_mobile_fu
      #      before_filter :force_mobile_format
      #    end
        
      def has_mobile_fu
        include ActionController::MobileFu::InstanceMethods

        helper_method :is_mobile_device?
        helper_method :in_mobile_view?
        helper_method :is_device?
      end
      
      def is_mobile_device?
        @@is_mobile_device
      end

      def in_mobile_view?
        @@in_mobile_view
      end

      def is_device?(type)
        @@is_device
      end
    end
    
    module InstanceMethods
      
      # Enables toggling of mobile view, despite detection
      def bypass_mobile_view(flag=nil)
        session[:bypass_mobile_view] = (flag.nil?) ? true : flag
      end
      
      def bypass_mobile_view?
        session[:bypass_mobile_view]
      end
      
      def check_for_bypass(param)
        if !params[param.to_sym].blank?
          bypass_mobile_view( params[param.to_sym] == 'true' )
        end
      end
      
      # Forces the request format to be :mobile
      
      def force_mobile_format
        request.format = :mobile
        session[:mobile_view] = true if session[:mobile_view].nil?
      end
      
      # Determines the request format based on whether the device is mobile or if
      # the user has opted to use either the 'Standard' view or 'Mobile' view.
      
      def set_mobile_format
        # FIXME: let user set the parameter to use
        check_for_bypass(:bypass)
        
        # don't mess with the format at all, unless we are dealing with html to begin with
        # if the device is mobile, and the user isn't opting out of the mobile view...
        if request.format == :html && is_mobile_device? && !bypass_mobile_view?
          session[:mobile_view] = true
          request.format = :mobile
        end
      end
      
      # Returns either true or false depending on whether or not the format of the
      # request is either :mobile or not.
      
      def in_mobile_view?
        request.format.to_sym == :mobile
      end
      
      # Returns either true or false depending on whether or not the user agent of
      # the device making the request is matched to a device in our regex.
      
      def is_mobile_device?
        request.user_agent.to_s.downcase =~ Regexp.new(ActionController::MobileFu::MOBILE_USER_AGENTS)
      end

      # Can check for a specific user agent
      # e.g., is_device?('iphone') or is_device?('mobileexplorer')
      
      def is_device?(type)
        request.user_agent.to_s.downcase.include?(type.to_s.downcase)
      end
    end
    
  end
  
end

ActionController::Base.send(:include, ActionController::MobileFu)