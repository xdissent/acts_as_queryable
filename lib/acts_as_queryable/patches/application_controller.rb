# encoding: utf-8

module ActsAsQueryable::Patches
  module ApplicationController
    extend Base

    def self.target
      ::ApplicationController
    end

    # Public: Class methods added to ActionController
    module ClassMethods

      # Public: Configure a controller to handle queries for a given model.
      # If not passed a queryable model class or name, the queryable model
      # is determined by looking at the controller name. The QueryableHelper
      # is included for the controller and views, and the find_query 
      # before_filter is enabled.
      #
      # klass          - The queryable class to use for the controller.
      # filter_options - Options Hash passed to the before_filter.
      #
      # Examples
      #
      #   class WidgetController < ApplicationController
      #
      #     # Each of the following would be identical for this controller.
      #     queryable
      #     queryable Widget
      #     queryable 'Widget'
      #
      #     # Each of the following would be identical for this controller.
      #     queryable :only => :index
      #     queryable Widget, :only => :index
      #     queryable 'Widget', :only => :index
      #
      #     def index
      #       # Fetch widgets from query.
      #       @widgets = @query.items
      #     end
      #   end
      # 
      def queryable(klass=nil, filter_options={})
        filter_options, klass = klass, nil if klass.is_a?(Hash)
        klass ||= name.sub("Controller", "").singularize
        klass = klass.constantize if klass.is_a?(String)
        
        # Bail unless we end up with a queryable class.
        return unless klass.queryable?

        # Store queryable class in controller.
        write_inheritable_attribute :queryable, klass
        
        # Include helpers.
        include ::QueryableHelper
        helper :queryable
        
        # Register filter.
        before_filter :find_query, filter_options
      end
    end
  end
end