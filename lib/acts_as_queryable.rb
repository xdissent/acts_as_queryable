# encoding: utf-8

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

  module Query
    class StatementInvalid < ActiveRecord::StatementInvalid; end
  end
end

require 'acts_as_queryable/patches/base'
require 'acts_as_queryable/patches/active_record_base'
require 'acts_as_queryable/patches/application_controller'

require 'acts_as_queryable/query/filters'
require 'acts_as_queryable/query/columns'
require 'acts_as_queryable/query/operators'
require 'acts_as_queryable/query/group_by'
require 'acts_as_queryable/query/sort'
require 'acts_as_queryable/query/sql'
require 'acts_as_queryable/query/validation'

require 'acts_as_queryable/helpers/scripts'
require 'acts_as_queryable/helpers/filters'
require 'acts_as_queryable/helpers/columns'
require 'acts_as_queryable/helpers/group_by'
require 'acts_as_queryable/helpers/sort'
require 'acts_as_queryable/helpers/list'

