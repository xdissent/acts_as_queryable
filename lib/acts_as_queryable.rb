# encoding: utf-8

require 'acts_as_queryable/patches/base'
require 'acts_as_queryable/patches/active_record_base'
require 'acts_as_queryable/patches/application_controller'

module ActsAsQueryable
  def queryable?
    false
  end

  def acts_as_queryable(options = {})
    return if queryable?
    
    class_inheritable_hash :queryable_options
    self.queryable_options = options

    extend ClassMethods
    include InstanceMethods

    query_class.queryable_class = self
    query_class.available_columns = options[:columns] if options[:columns]
    query_class.available_filters = options[:filters] if options[:filters]
    query_class.operators = options[:operators] if options[:operators]
    query_class.operators_by_filter_type = options[:operators_by_filter_type] if options[:operators_by_filter_type]
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