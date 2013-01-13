# encoding: utf-8

require 'redmine/acts/queryable/patches/base'
require 'redmine/acts/queryable/patches/active_record_base'
require 'redmine/acts/queryable/patches/application_controller'

module Redmine
  module Acts
    module Queryable
      def queryable?
        false
      end

      def acts_as_queryable(options = {})
        return if queryable?
        
        class_inheritable_hash :queryable_options
        self.queryable_options = options

        extend ClassMethods
        include InstanceMethods

        query_class.send :queryable_class=, self
        query_class.send :available_columns=, options[:columns] if options[:columns]
        query_class.send :available_filters=, options[:filters] if options[:filters]
      end

      module ClassMethods
        def queryable?
          true
        end

        def query_class_name
          queryable_options[:class_name] || "#{name.gsub("::", "_")}Query"
        end

        def query_class
          unless Object.const_defined?(query_class_name)
            Object.const_set query_class_name, Class.new(QueryableQuery)
          end
          query_class_name.constantize
        end
      end

      module InstanceMethods
        def query_class
          self.class.query_class
        end
      end
    end
  end
end
