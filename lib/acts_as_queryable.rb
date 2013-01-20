# encoding: utf-8

module ActsAsQueryable

  # Public: Determine whether a model class acts as queryable. Initially false,
  # this method is overridden when a model becomes queryable.
  #
  # Returns boolean indicating queryableness.
  def queryable?
    false
  end

  # Public: Set up a model as a queryable class.
  #
  # Returns nothing.
  def acts_as_queryable(options = {})
    return if queryable?
    
    # Store queryable options as Hash on queryable model class.
    class_inheritable_hash :queryable_options
    self.queryable_options = options

    # Add queryable methods to model.
    extend ClassMethods
    include InstanceMethods

    # Set up the query class.
    query_class.queryable_class = self
    query_class.available_columns = options[:columns] if options[:columns]
    query_class.available_filters = options[:filters] if options[:filters]
    query_class.operators = options[:operators] if options[:operators]
    query_class.operators_by_filter_type = options[:operators_by_filter_type] if options[:operators_by_filter_type]
  end

  # Public: Class methods added to the queryable model class.
  module ClassMethods

    # Public: Determine whether a model class acts as queryable. Initially false,
    # this method is overridden when a model becomes queryable.
    #
    # Returns boolean indicating queryableness.
    def queryable?
      true
    end

    # Public: Fetch the query class name from the queryable options or 
    # generate a default from the queryable class name.
    #
    # Returns a String query class name.
    def query_class_name
      queryable_options[:class_name] || "#{name.gsub("::", "_")}Query"
    end

    # Public: Find or create a query class for a queryable model class. If no
    # class with the given name is found, one is created by extending 
    # QueryableQuery.
    #
    # Returns the query class.
    def query_class
      unless Object.const_defined?(query_class_name)
        Object.const_set query_class_name, Class.new(QueryableQuery)
      end
      query_class_name.constantize
    end
  end

  # Public: Instance methods added to the queryable model class.
  module InstanceMethods

    # Public: Fetch the query class for a queryable model instance. 
    #
    # Returns the query class.
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
require 'acts_as_queryable/query/sort_criteria'
require 'acts_as_queryable/query/sql'
require 'acts_as_queryable/query/validation'

require 'acts_as_queryable/helpers/scripts'
require 'acts_as_queryable/helpers/filters'
require 'acts_as_queryable/helpers/columns'
require 'acts_as_queryable/helpers/group_by'
require 'acts_as_queryable/helpers/sort_criteria'
require 'acts_as_queryable/helpers/list'
require 'acts_as_queryable/helpers/form'

